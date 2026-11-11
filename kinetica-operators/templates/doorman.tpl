{{/*
Static circuit-breaker ingress "doorman" replacing ingress-nginx.

Rubix disallows cluster-wide RBAC and Gateway API objects, so this renders the
same footprint ingress-nginx occupied: a Deployment + ClusterIP Service (with
the Rubix SPP / pod-cert annotations) + a ConfigMap holding the proxy's static
routing config. No operator, no CRDs, no gateway.networking.k8s.io kinds, no
Kubernetes API access at runtime — upstreams are addressed by Service DNS.

The route table transcribes the Ingress objects the dboperator/wboperator
generate for ingressController "nginx" (same table as gateway.tpl):

  gadmin     /<pathPrefix>/gadmin -> <cluster>-gadmin-service:8080, prefix stripped
  ranks      /<clusterName>/gpudb-N[/hostmanager] -> <cluster>-rankN-service:8082/9300 (rank0..rank<replicas>)
  workbench  sub-path: /<pathPrefix> catch-all (prefix stripped); root: /workbench -> <wbName>-workbench-service:8000

Rules are listed longest-prefix-first so both first-match and Gateway-API
precedence semantics select the same rule. Upstream holds are enabled by
default (binding hold omitted), so clients park instead of erroring while the
DB restarts. ALPN is pinned to http/1.1. A response-header-modify stage emits
Connection: close on every response — an interim mitigation because the proxy
pins the upstream per connection, so keep-alive reuse across routes would
otherwise misroute; remove it once the proxy does per-request dispatch.

Response-side parity with nginx (proxy_redirect / proxy_cookie_path / the
configuration-snippet ?redirect= regex): when a pathPrefix is in play, the
binding pipeline carries response-direction location-rewrite and cookie-modify
pathRewrite stages. Both run in auto mode — they act only on responses whose
request actually had a prefix stripped (keyed off the http-rewrite
stripped-prefix metadata) — and the location-rewrite stage additionally
carries the regex rule re-prefixing GAdmin's ?redirect= login query param.
Workbench remains prefix-aware via its BASE_PATH env.
*/}}

{{- define "kinetica-operators.doorman.config" }}
{{- $values := .Values }}
{{- $dm := $values.doorman }}
{{- $ns := $values.kineticacluster.namespace }}
{{- $clusterName := $values.kineticacluster.name }}
{{- $prefix := $values.kineticacluster.pathPrefix | default "" }}
{{- $wbName := $values.workbench.name | default "workbench" }}
{{- $wbNs := $values.workbench.namespace | default $ns }}
{{- /* Fully-qualified with trailing dot: the doorman resolves upstreams on every
       connection, and an unqualified name costs extra search-list queries and
       20s stalls when cluster DNS drops a packet. */}}
{{- $clusterDomain := $dm.clusterDomain | default "cluster.local" }}
{{- $wbPrefix := $values.workbench.pathPrefix | default $prefix }}
{{- /* dboperator creates rank ingresses for rank0..rank<replicas> INCLUSIVE */}}
{{- $ranks := add1 (int (dig "gpudbCluster" "replicas" 1 $values.kineticacluster)) }}
{{- if $dm.ranks }}{{- $ranks = int $dm.ranks }}{{- end }}
{{- /* Ring failover (doorman.ha): when a peer head address is set, every rank
       http route names it as backupRef so the proxy fails over to the ring peer
       when the local rank is unreachable, instead of only holding. The peer is
       used only while its readyCheck passes (ha_status drained), otherwise the
       connection holds as before. Unset = exactly the pre-existing render. */}}
{{- $ha := $dm.ha | default dict }}
{{- $haEnabled := $ha.enabled | default false }}
{{- $peer := $ha.peer | default dict }}
{{- $peerHost := "" }}
{{- if $haEnabled }}{{- $peerHost = $peer.host | default "" }}{{- end }}
{{- $rc := $ha.readyCheck | default dict }}
{{- $rcEnabled := false }}
{{- if $peerHost }}{{- $rcEnabled = ternary $rc.enabled true (hasKey $rc "enabled") }}{{- end }}
{{- $peerTransport := $peer.transport | default "HTTP" }}
managementPort: 2222
ha:
  enabled: false
otel:
  enable: true
  logToStdout: true
  transport: stdout
facades:
  doorman:
    name: https
    interface: "0.0.0.0"
    ports:
      - name: https
        port: {{ $dm.listener.port }}
        transport: HTTPS
    tls:
      certFile: /etc/doorman-tls/tls.crt
      keyFile: /etc/doorman-tls/tls.key
      # http/1.1 only: h2 through the proxy is not validated and browsers
      # prefer it when offered.
      alpnProtocols:
        - http/1.1
upstreams:
  gadmin:
    name: gadmin
    host: {{ $clusterName }}-gadmin-service.{{ $ns }}.svc.{{ $clusterDomain }}.
    ports:
      - name: http
        port: 8080
        transport: HTTP
{{- range $i := until (int $ranks) }}
  rank{{ $i }}:
    name: rank{{ $i }}
    host: {{ $clusterName }}-rank{{ $i }}-service.{{ $ns }}.svc.{{ $clusterDomain }}.
    ports:
      - name: http
        port: 8082
        transport: HTTP
      - name: hostmanager
        port: 9300
        transport: HTTP
{{- end }}
  workbench:
    name: workbench
    host: {{ $wbName }}-workbench-service.{{ $wbNs }}.svc.{{ $clusterDomain }}.
    ports:
      - name: http
        port: 8000
        transport: HTTP
{{- if $peerHost }}
  peer-rank0:
    name: peer-rank0
    host: {{ $peerHost }}
    ports:
      - name: http
        port: {{ $peer.port | default 8082 }}
        transport: {{ $peerTransport }}
{{- if $rcEnabled }}
    # Failover gate: the peer is dialled only while this probe passes. The
    # response embeds ha_status as escaped JSON, hence the backslashes in match.
    readyCheck:
      path: {{ $rc.path | default "/gpudb-0/show/system/status" }}
      method: POST
      body: '{"options":{}}'
      scheme: {{ ternary "https" "http" (eq (upper $peerTransport) "HTTPS") }}
      authEnv: KINETICA_HA_PROBE_AUTH
      match: {{ $rc.match | default "drained\\\\\\\":\\\\\\\"drained" | quote }}
      timeoutSec: {{ $rc.timeoutSec | default 3 }}
      cacheSec: {{ $rc.cacheSec | default 5 }}
{{- end }}
{{- end }}
pipelines:
{{- range $i := until (int $ranks) }}
  strip-rank{{ $i }}-hostmanager:
    name: strip-rank{{ $i }}-hostmanager
    stages:
      - stage: http-rewrite
        direction: request
        config:
          requestRewrite:
            path:
              type: ReplacePrefixMatch
              replacePrefixMatch: /{{ $clusterName }}/gpudb-{{ $i }}/hostmanager
              replacement: /
  strip-rank{{ $i }}-httpd:
    name: strip-rank{{ $i }}-httpd
    stages:
      - stage: http-rewrite
        direction: request
        config:
          requestRewrite:
            path:
              type: ReplacePrefixMatch
              replacePrefixMatch: /{{ $clusterName }}/gpudb-{{ $i }}
              replacement: /gpudb-{{ $i }}
{{- end }}
{{- if $haEnabled }}
{{- range $i := until (int $ranks) }}
  strip-bare-rank{{ $i }}-hostmanager:
    name: strip-bare-rank{{ $i }}-hostmanager
    stages:
      - stage: http-rewrite
        direction: request
        config:
          requestRewrite:
            path:
              type: ReplacePrefixMatch
              replacePrefixMatch: /gpudb-{{ $i }}/hostmanager
              replacement: /
{{- end }}
{{- end }}
{{- if $prefix }}
  strip-gadmin:
    name: strip-gadmin
    stages:
      - stage: http-rewrite
        direction: request
        config:
          requestRewrite:
            path:
              type: ReplacePrefixMatch
              replacePrefixMatch: /{{ $prefix }}/gadmin
              replacement: /gadmin
{{- end }}
{{- if $wbPrefix }}
  strip-workbench:
    name: strip-workbench
    stages:
      - stage: http-rewrite
        direction: request
        config:
          requestRewrite:
            path:
              type: ReplacePrefixMatch
              replacePrefixMatch: /{{ $wbPrefix }}
              replacement: /
{{- end }}
bindings:
  doorman:
    name: doorman
    facade: doorman
{{- $shield := $dm.holdShield | default dict }}
{{- if $shield.enabled }}
    # Tier-3 probe shielding: while holding (DB down), answer the Kinetica
    # client liveness probes from the last healthy cached response so drivers
    # never conclude the DB is dead. Data requests still park as before.
    hold:
      shieldEnabled: true
      shieldPaths:
{{- range ($shield.paths | default (list "/show/system/status" "/show/system/properties")) }}
        - {{ . | quote }}
{{- end }}
      shieldMaxResponseBytes: {{ $shield.maxResponseBytes | default 65536 }}
{{- end }}
    pipeline:
      stages:
        # TLS is terminated by this stage; certFile/keyFile/alpnProtocols are
        # injected from the facade tls block (injectFacadeTLS).
        - stage: tls-termination
          direction: request
          config: {}
        # Ask the upstream to close after every response. The proxy frames an
        # upstream response that has neither Content-Length nor chunked
        # encoding (e.g. 304 Not Modified) by reading until the server closes,
        # so a keep-alive upstream stalls every 304 for its keep-alive timeout
        # (Tomcat: 20s). One request per upstream connection also matches the
        # Connection: close enforced on the response side below.
        - stage: request-header-modify
          direction: request
          config:
            set:
              - name: Connection
                value: close
        - stage: gateway-router
          direction: request
          config:
            rules:
{{- range $i := until (int $ranks) }}
              - matches:
                  - path: {type: PathPrefix, value: /{{ $clusterName }}/gpudb-{{ $i }}/hostmanager}
                backendRef: rank{{ $i }}
                backendPort: hostmanager
                target: strip-rank{{ $i }}-hostmanager
{{- end }}
{{- if $peerHost }}
{{- /* The SDK discovery calls must be answered by this cluster or not at all:
       answered by the peer they make this address look like the peer cluster,
       and an auto-discovering client then never finishes connecting. Exact
       rules outrank the rank prefix rules below and carry no backupRef. */}}
{{- range $i := until (int $ranks) }}
              - matches:
                  - path: {type: Exact, value: /{{ $clusterName }}/gpudb-{{ $i }}/show/system/status}
                  - path: {type: Exact, value: /{{ $clusterName }}/gpudb-{{ $i }}/show/system/properties}
                backendRef: rank{{ $i }}
                backendPort: http
                target: strip-rank{{ $i }}-httpd
              - matches:
                  - path: {type: Exact, value: /gpudb-{{ $i }}/show/system/status}
                  - path: {type: Exact, value: /gpudb-{{ $i }}/show/system/properties}
                backendRef: rank{{ $i }}
                backendPort: http
{{- end }}
{{- end }}
{{- range $i := until (int $ranks) }}
              - matches:
                  - path: {type: PathPrefix, value: /{{ $clusterName }}/gpudb-{{ $i }}}
                backendRef: rank{{ $i }}
                backendPort: http
{{- if $peerHost }}
                backupRef: peer-rank0
                backupPort: http
{{- end }}
                target: strip-rank{{ $i }}-httpd
{{- end }}
{{- if $haEnabled }}
{{- /* Ring mode: members advertise rank 0 as <publicAddress>:<httpd port>/gpudb-0
       and workers as <publicURLBase>/gpudb-N, i.e. the bare paths the rank
       httpd serves natively. Route them here too (no prefix to strip) so the
       advertised URLs resolve through this proxy; listener.port must then be
       the DB httpd port (8082). */}}
{{- range $i := until (int $ranks) }}
              - matches:
                  - path: {type: PathPrefix, value: /gpudb-{{ $i }}/hostmanager}
                backendRef: rank{{ $i }}
                backendPort: hostmanager
                target: strip-bare-rank{{ $i }}-hostmanager
{{- end }}
{{- range $i := until (int $ranks) }}
              - matches:
                  - path: {type: PathPrefix, value: /gpudb-{{ $i }}}
                backendRef: rank{{ $i }}
                backendPort: http
{{- if $peerHost }}
                backupRef: peer-rank0
                backupPort: http
{{- end }}
{{- end }}
{{- end }}
{{- if $prefix }}
              - matches:
                  - path: {type: PathPrefix, value: /{{ $prefix }}/gadmin}
                backendRef: gadmin
                backendPort: http
                target: strip-gadmin
{{- else }}
              - matches:
                  - path: {type: PathPrefix, value: /gadmin}
                backendRef: gadmin
                backendPort: http
{{- end }}
{{- if $wbPrefix }}
              - matches:
                  - path: {type: PathPrefix, value: /{{ $wbPrefix }}}
                backendRef: workbench
                backendPort: http
                target: strip-workbench
{{- else }}
              # Root-path mode: workbench is the CATCH-ALL, mirroring the
              # wboperator's nginx root-mode Ingress (empty path + app-root
              # annotation = `/` prefix). The app calls /graphql, /api, ...
              # at the HOST ROOT (config_production.js API_URL), so routing
              # only /workbench blank-screens the UI. Must stay the LAST rule.
              - matches:
                  - path: {type: PathPrefix, value: /}
                backendRef: workbench
                backendPort: http
{{- end }}
        # Force one-request-per-connection: emit Connection: close on every
        # response so pooling front proxies (platform Envoy, browsers) cannot
        # reuse a TCP connection across different rank/app routes. INTERIM
        # mitigation — the proxy resolves the upstream ONCE per connection, so a
        # keep-alive follow-up request for a different route is delivered to the
        # first request's backend (misroute). Closing the connection after each
        # response forces the client to re-open and be re-routed. Remove when the
        # proxy gains per-request upstream dispatch.
        - stage: response-header-modify
          direction: response
          config:
            set:
              - name: Connection
                value: close
            remove:
              - Keep-Alive
{{- if or $prefix $wbPrefix }}
        # Response-direction prefix restoration (nginx proxy_redirect /
        # proxy_cookie_path parity). Auto mode acts only on responses whose
        # request had a prefix stripped by a strip-* pipeline above.
        - stage: location-rewrite
          direction: response
          config:
            mode: auto
{{- if $prefix }}
            rules:
              # GAdmin's AuthFilter embeds the ORIGINAL (post-strip) path in
              # the login redirect query param (?redirect=/gadmin/...); the
              # built-in logic re-prefixes only the path portion of the
              # header. This rule restores the prefix inside the param.
              # IMPORTANT: no ${...} may appear here — the proxy's secrets
              # resolver claims every ${...} token at load time and DROPS the
              # whole stage on a non-secret token. Braceless $1/$2 group refs
              # and the literal prefix avoid that. Anchoring to /gadmin makes
              # the rule idempotent (a rewritten value no longer has /gadmin
              # directly after redirect=).
              - match: "([?&]redirect=)/gadmin(/[^&]*)?"
                replace: "$1/{{ $prefix }}/gadmin$2"
{{- end }}
        - stage: cookie-modify
          direction: response
          config:
            response:
              pathRewrite:
                mode: auto
{{- end }}
    # gateway-router owns all routing and returns 404 on no match, so this
    # `main` upstream is a required placeholder, never a fallback — unmatched
    # traffic 404s rather than landing here.
    main:
      facade: doorman
      upstream: workbench
      mapping:
        - name: https_map
          clientPort: https
          upstreamPort: http
{{- end }}

{{- define "kinetica-operators.doorman" }}
{{- $root := . }}
{{- $values := .Values }}
{{- $dm := $values.doorman }}
{{- $ns := $values.kineticacluster.namespace }}
{{- $clusterName := $values.kineticacluster.name }}
{{- $name := printf "%s-doorman" $clusterName }}
{{- $fqdn := dig "gpudbCluster" "fqdn" "" $values.kineticacluster }}
{{- $tlsSecret := $dm.listener.tlsSecretName }}
{{- if and (not $tlsSecret) $dm.listener.selfSigned }}
{{- $tlsSecret = printf "%s-tls" $name }}
{{- end }}
{{- $labels := dict "app.kubernetes.io/name" "circuit-breaker-doorman" "app.kubernetes.io/instance" $name "app.kubernetes.io/managed-by" "Helm" }}
{{- if and $dm.listener.selfSigned (not $dm.listener.tlsSecretName) }}
{{- /* Parity with ingress-nginx's built-in self-signed default certificate;
       upstream Envoy does not pin it. Set listener.tlsSecretName (e.g. the
       Rubix pod-cert secret cert-<service>) to serve a managed certificate
       instead. Generated ONCE and reused across upgrades via lookup: without
       reuse, genSelfSignedCert emits a new key every render, rewriting this
       Secret (churn) while the checksum/config annotation — which covers only
       the config — leaves the pods un-restarted to reload it. NOTE: lookup only
       sees the cluster during a real `helm install/upgrade`; under
       `helm template | kubectl apply` it returns empty and a fresh cert is
       generated each render (harmless — same behaviour as before). */}}
{{- $cn := $fqdn | default $clusterName }}
{{- $existing := lookup "v1" "Secret" $ns $tlsSecret }}
{{- $crt := "" }}
{{- $key := "" }}
{{- if $existing }}
{{- $crt = index ($existing.data | default dict) "tls.crt" | default "" }}
{{- $key = index ($existing.data | default dict) "tls.key" | default "" }}
{{- end }}
{{- if or (not $crt) (not $key) }}
{{- $gen := genSelfSignedCert $cn nil (list $cn) 3650 }}
{{- $crt = $gen.Cert | b64enc }}
{{- $key = $gen.Key | b64enc }}
{{- end }}
---
apiVersion: v1
kind: Secret
type: kubernetes.io/tls
metadata:
  name: {{ $tlsSecret }}
  namespace: {{ $ns }}
  labels: {{- toYaml $labels | nindent 4 }}
data:
  tls.crt: {{ $crt }}
  tls.key: {{ $key }}
{{- end }}
{{- /* Management API (:2222) bearer token. Without CB_MGMT_TOKEN the pause/
       resume/drain/stop endpoints are unauthenticated to anything that can
       reach the pod IP. Generated once and reused across upgrades via lookup
       (same cluster-connected caveat as the TLS cert above). /healthz, /readyz
       and /prestop are auth-exempt, so probes and the preStop hook keep
       working with the token set. */}}
{{- $mgmtSecret := printf "%s-mgmt" $name }}
{{- $existingMgmt := lookup "v1" "Secret" $ns $mgmtSecret }}
{{- $mgmtToken := "" }}
{{- if $existingMgmt }}
{{- $mgmtToken = index ($existingMgmt.data | default dict) "token" | default "" }}
{{- end }}
{{- if not $mgmtToken }}
{{- $mgmtToken = randAlphaNum 40 | b64enc }}
{{- end }}
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ $mgmtSecret }}
  namespace: {{ $ns }}
  labels: {{- toYaml $labels | nindent 4 }}
data:
  token: {{ $mgmtToken }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ $name }}
  namespace: {{ $ns }}
  labels: {{- toYaml $labels | nindent 4 }}
automountServiceAccountToken: false
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $name }}-config
  namespace: {{ $ns }}
  labels: {{- toYaml $labels | nindent 4 }}
data:
  circuitbreaker.yaml: |
    {{- include "kinetica-operators.doorman.config" $root | nindent 4 }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $name }}
  namespace: {{ $ns }}
  labels: {{- toYaml $labels | nindent 4 }}
spec:
  replicas: {{ $dm.replicas | default 2 }}
  {{- if $dm.requireReplicaSpread }}
  # With hard replica spread, a surge pod has no eligible node when eligible
  # nodes == replicas, stalling rollouts Pending forever. Recycle in place
  # instead: take one replica down, then schedule its replacement on the freed
  # node (brief one-replica window — same posture the PDB already accepts).
  strategy:
    rollingUpdate:
      maxSurge: 0
      maxUnavailable: 1
  {{- end }}
  selector:
    matchLabels:
      app.kubernetes.io/name: circuit-breaker-doorman
      app.kubernetes.io/instance: {{ $name }}
  template:
    metadata:
      labels: {{- toYaml $labels | nindent 8 }}
      annotations:
        checksum/config: {{ include "kinetica-operators.doorman.config" $root | sha256sum }}
    spec:
      serviceAccountName: {{ $name }}
      automountServiceAccountToken: false
      affinity:
        podAntiAffinity:
          {{- if not $dm.requireReplicaSpread }}
          # Prefer spreading replicas across nodes for HA; soft so a single-node
          # cluster (local k3s/kind) can still schedule the full replica count.
          # Set requireReplicaSpread: true on multi-node clusters to make this
          # a hard rule instead.
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                topologyKey: kubernetes.io/hostname
                labelSelector:
                  matchLabels:
                    app.kubernetes.io/name: circuit-breaker-doorman
                    app.kubernetes.io/instance: {{ $name }}
          {{- end }}
          {{- if or $dm.requireReplicaSpread $dm.avoidDBNodes }}
          requiredDuringSchedulingIgnoredDuringExecution:
            {{- if $dm.requireReplicaSpread }}
            # HARD: at most one doorman replica per node, so a single node loss
            # (or Rubix node cycle) can never take out both replicas at once.
            # Requires >= replicas schedulable nodes — leave unset (false) on
            # single-node clusters (k3s/kind) or the doorman stays Pending.
            - topologyKey: kubernetes.io/hostname
              labelSelector:
                matchLabels:
                  app.kubernetes.io/name: circuit-breaker-doorman
                  app.kubernetes.io/instance: {{ $name }}
            {{- end }}
            {{- if $dm.avoidDBNodes }}
            # HARD: never co-locate a doorman replica on a node running Kinetica
            # DB (gpudb StatefulSet) pods, so a DB-node drain/restart cannot evict
            # a doorman replica along with the database. Requires at least one node
            # NOT running a DB pod to place the replicas — DO NOT enable on a
            # single-node cluster (k3s/kind) or the doorman will stay Pending.
            # DB pods are co-namespaced with the doorman, so default (same-
            # namespace) matching applies; the label is the dboperator's gpudb
            # StatefulSet name label.
            - topologyKey: kubernetes.io/hostname
              labelSelector:
                matchLabels:
                  app.kubernetes.io/name: {{ $clusterName }}-gpudb-statefulset
            {{- end }}
          {{- end }}
      {{- with $dm.imagePullSecrets }}
      imagePullSecrets: {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - name: circuit-breaker
          image: "{{ include "kinetica-operators.image" (dict "registry" ($dm.image.registry | default $values.global.image.registry) "repository" $dm.image.repository "tag" ($dm.image.tag | default $values.global.image.tag)) }}"
          imagePullPolicy: {{ $dm.image.pullPolicy | default "IfNotPresent" }}
          args:
            - serve
            - --config
            - /opt/gpudb/circuit-breaker/config/circuitbreaker.yaml
          env:
            # Gates the management API (:2222 pause/resume/drain/stop).
            # /healthz, /readyz and /prestop are auth-exempt, so the probes and
            # preStop hook below are unaffected.
            - name: CB_MGMT_TOKEN
              valueFrom:
                secretKeyRef:
                  name: {{ $name }}-mgmt
                  key: token
            # Standard OTEL SDK env switches (honored by the proxy): disable
            # metric/trace export so stdout carries log records only. Without
            # these the stdout metrics exporter writes ~6KB every 10s, which
            # churns kubelet log rotation and buries the event log in noise
            # (learned on Pelennor: the node-cycle forensics had rotated away).
            - name: OTEL_METRICS_EXPORTER
              value: "none"
            - name: OTEL_TRACES_EXPORTER
              value: "none"
{{- $ha := $dm.ha | default dict }}
{{- $peerHost := dig "peer" "host" "" $ha }}
{{- $rc := $ha.readyCheck | default dict }}
{{- if and ($ha.enabled | default false) $peerHost (ternary $rc.enabled true (hasKey $rc "enabled")) }}
{{- if not $rc.secretName }}
{{- fail "doorman.ha.readyCheck.secretName is required when doorman.ha is enabled with a peer.host and readyCheck is enabled: a Secret in the DB namespace whose key holds \"user:password\" for the peer status probe" }}
{{- end }}
            # Credentials for the ring-peer readiness probe (doorman.ha.readyCheck),
            # "user:password" from a pre-created Secret, never from values.
            - name: KINETICA_HA_PROBE_AUTH
              valueFrom:
                secretKeyRef:
                  name: {{ $rc.secretName }}
                  key: {{ $rc.secretKey | default "auth" }}
{{- end }}
{{- $peerCA := and ($ha.enabled | default false) $peerHost }}
{{- $caConfigMap := dig "gpudbCluster" "config" "ha" "caConfigMapName" "" ($root.Values.kineticacluster | default dict) }}
{{- if $peerCA }}
            # Extra certificate authorities for the ring peer's HTTPS address (a
            # private CA), on top of the image's public ones.
            - name: SSL_CERT_DIR
              value: /etc/doorman-peer-ca:/etc/ssl/certs
{{- end }}
          ports:
            - name: https
              containerPort: {{ $dm.listener.port }}
              protocol: TCP
            - name: mgmt
              containerPort: 2222
              protocol: TCP
          readinessProbe:
            httpGet: {path: /circuit-breaker/healthz, port: 2222, scheme: HTTP}
            initialDelaySeconds: 5
            periodSeconds: 5
            timeoutSeconds: 3
          livenessProbe:
            httpGet: {path: /circuit-breaker/healthz, port: 2222, scheme: HTTP}
            initialDelaySeconds: 15
            periodSeconds: 10
            failureThreshold: 6
            timeoutSeconds: 3
          lifecycle:
            preStop:
              httpGet: {path: /circuit-breaker/prestop, port: 2222, scheme: HTTP}
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
            readOnlyRootFilesystem: true
            runAsNonRoot: true
            runAsUser: 10001
            seccompProfile:
              type: RuntimeDefault
          # Defaults for a lightweight streaming proxy; override the whole block
          # via doorman.resources (e.g. raise limits for high ingest throughput).
          # Requests are set so the pod is not BestEffort QoS and schedules under
          # restricted / resource-quota'd (Rubix) namespaces.
          {{- if $dm.resources }}
          resources: {{- toYaml $dm.resources | nindent 12 }}
          {{- else }}
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: "1"
              memory: 512Mi
          {{- end }}
          volumeMounts:
            - name: config
              mountPath: /opt/gpudb/circuit-breaker/config/circuitbreaker.yaml
              subPath: circuitbreaker.yaml
              readOnly: true
            - name: tls
              mountPath: /etc/doorman-tls
              readOnly: true
{{- if $peerCA }}
            - name: peer-ca
              mountPath: /etc/doorman-peer-ca
              readOnly: true
{{- end }}
      volumes:
        - name: config
          configMap:
            name: {{ $name }}-config
        - name: tls
          secret:
            secretName: {{ $tlsSecret }}
{{- if $peerCA }}
        # The CA that signed the peer's certificate: the ConfigMap named in
        # kineticacluster config.ha.caConfigMapName, else the ca.crt shipped in
        # this site's own TLS Secret (absent there: public authorities only).
        - name: peer-ca
{{- if $caConfigMap }}
          configMap:
            name: {{ $caConfigMap }}
            items:
              - key: ca.crt
                path: ca.crt
{{- else }}
          secret:
            secretName: {{ $tlsSecret }}
            optional: true
            items:
              - key: ca.crt
                path: ca.crt
{{- end }}
{{- end }}
{{- if gt (int ($dm.replicas | default 2)) 1 }}
---
# Keep at least one doorman serving through voluntary disruptions (node
# drains, upgrades). Rendered only for multi-replica deployments so a
# single-replica install never deadlocks a drain.
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ $name }}
  namespace: {{ $ns }}
  labels: {{- toYaml $labels | nindent 4 }}
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: circuit-breaker-doorman
      app.kubernetes.io/instance: {{ $name }}
{{- end }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ $name }}
  namespace: {{ $ns }}
  labels: {{- toYaml $labels | nindent 4 }}
  {{- with $dm.service.annotations }}
  # The SPP annotation is how the Rubix platform Envoy routes external traffic
  # here; the endpoint name must equal the Service port name, and targetPort
  # must name a container port. Values are rendered through `tpl` (so they may
  # reference chart values); conversely a value containing literal, non-template
  # Go-template delimiters would be misparsed — keep annotation values free of
  # stray braces.
  annotations:
    {{- range $k, $v := . }}
    {{ $k }}: {{ tpl ($v | toString) $root | quote }}
    {{- end }}
  {{- end }}
spec:
  type: {{ $dm.service.type | default "ClusterIP" }}
  selector:
    app.kubernetes.io/name: circuit-breaker-doorman
    app.kubernetes.io/instance: {{ $name }}
  ports:
    - name: https
      port: {{ $dm.listener.port }}
      targetPort: https
      protocol: TCP
{{- end }}
