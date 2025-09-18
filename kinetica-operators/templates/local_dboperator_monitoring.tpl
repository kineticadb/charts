{{- define "kinetica-operators.local-dboperator-monitoring" }}

---
{{- if .Values.kubeStateMetrics.install }}
apiVersion: v1
automountServiceAccountToken: false
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/name: kube-state-metrics
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app.kubernetes.io/component: exporter
    app.kubernetes.io/version: 2.4.2
  name: kube-state-metrics
  namespace: kinetica-system
{{- end }}
---
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: opentelemetry-collector
  namespace: kinetica-system
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'

---
{{- if .Values.kubeStateMetrics.install }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: kube-state-metrics
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app.kubernetes.io/component: exporter
    app.kubernetes.io/version: 2.4.2
  name: kube-state-metrics
rules:
- apiGroups:
  - ''
  resources:
  - configmaps
  - secrets
  - nodes
  - pods
  - services
  - resourcequotas
  - replicationcontrollers
  - limitranges
  - persistentvolumeclaims
  - persistentvolumes
  - namespaces
  - endpoints
  verbs:
  - list
  - watch
- apiGroups:
  - apps
  resources:
  - statefulsets
  - daemonsets
  - deployments
  - replicasets
  verbs:
  - list
  - watch
- apiGroups:
  - batch
  resources:
  - cronjobs
  - jobs
  verbs:
  - list
  - watch
- apiGroups:
  - autoscaling
  resources:
  - horizontalpodautoscalers
  verbs:
  - list
  - watch
- apiGroups:
  - authentication.k8s.io
  resources:
  - tokenreviews
  verbs:
  - create
- apiGroups:
  - authorization.k8s.io
  resources:
  - subjectaccessreviews
  verbs:
  - create
- apiGroups:
  - policy
  resources:
  - poddisruptionbudgets
  verbs:
  - list
  - watch
- apiGroups:
  - certificates.k8s.io
  resources:
  - certificatesigningrequests
  verbs:
  - list
  - watch
- apiGroups:
  - storage.k8s.io
  resources:
  - storageclasses
  - volumeattachments
  verbs:
  - list
  - watch
- apiGroups:
  - admissionregistration.k8s.io
  resources:
  - mutatingwebhookconfigurations
  - validatingwebhookconfigurations
  verbs:
  - list
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - networkpolicies
  - ingresses
  verbs:
  - list
  - watch
- apiGroups:
  - coordination.k8s.io
  resources:
  - leases
  verbs:
  - list
  - watch
{{- end }}
---
{{ if .Values.otelCollector.installRbac }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: otel-collector-role
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
rules:
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
{{ end }}

---
{{- if .Values.kubeStateMetrics.install }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app.kubernetes.io/name: kube-state-metrics
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app.kubernetes.io/component: exporter
    app.kubernetes.io/version: 2.4.2
  name: kube-state-metrics
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kube-state-metrics
subjects:
- kind: ServiceAccount
  name: kube-state-metrics
  namespace: kinetica-system
{{- end }}
---
{{ if .Values.otelCollector.installRbac }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: otel-collector-role-binding
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: otel-collector-role
subjects:
- kind: ServiceAccount
  name: opentelemetry-collector
  namespace: kinetica-system
{{ end }}

---
{{- if .Values.otelCollector.install }}
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app.kubernetes.io/name: otel-collector
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app: opentelemetry
    component: otel-collector-conf
  name: otel-collector-conf
  namespace: kinetica-system
data:
  {{ (.Files.Glob "files/configmaps/local-dboperator-monitoring-otel-collector-conf.yaml").AsConfig }}
{{- end }}
---
---
{{- if .Values.kubeStateMetrics.install }}
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/name: kube-state-metrics
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app.kubernetes.io/component: exporter
    app.kubernetes.io/version: 2.4.2
  name: kube-state-metrics
  namespace: kinetica-system
spec:
  clusterIP: None
  ports:
  - name: http-metrics
    port: 8080
    targetPort: http-metrics
  - name: telemetry
    port: 8081
    targetPort: telemetry
  selector:
    app.kubernetes.io/name: kube-state-metrics
{{- end }}
---
---
{{- if .Values.otelCollector.install }}
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/name: otel-collector
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app: opentelemetry
    component: otel-collector
  name: otel-collector
  namespace: kinetica-system
spec:
  ports:
  - name: syslog
    port: 9601
    protocol: TCP
    targetPort: 9601
  - name: otlp-rpc
    port: 4317
    protocol: TCP
    targetPort: 4317
  - name: otlp-http
    port: 4318
    protocol: TCP
    targetPort: 4318
  - name: fluentforward
    port: 8006
    protocol: TCP
    targetPort: 8006
  - name: metrics
    port: 8889
    protocol: TCP
    targetPort: 8889
  - name: zpages
    port: 55679
    protocol: TCP
    targetPort: 55679
  selector:
    component: otel-collector
  type: ClusterIP
{{- end }}
---
---
{{- if .Values.kubeStateMetrics.install }}
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    prometheus.io/path: /metrics
    prometheus.io/port: '8080'
    prometheus.io/scrape: 'true'
  labels:
    app.kubernetes.io/name: kube-state-metrics
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app.kubernetes.io/component: exporter
    app.kubernetes.io/version: 2.4.2
  name: kube-state-metrics
  namespace: kinetica-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: kube-state-metrics
  template:
    metadata:
      annotations:
        prometheus.io/path: /metrics
        prometheus.io/port: '8080'
        prometheus.io/scheme: http
        prometheus.io/scrape: 'true'
      labels:
        app.kubernetes.io/component: exporter
        app.kubernetes.io/name: kube-state-metrics
        app.kubernetes.io/version: 2.4.2
    spec:
      automountServiceAccountToken: true
      containers:
      - image: '{{ .Values.kubeStateMetrics.image.repository }}:{{ .Values.kubeStateMetrics.image.tag
          }}'
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 5
          timeoutSeconds: 5
        name: kube-state-metrics
        ports:
        - containerPort: 8080
          name: http-metrics
        - containerPort: 8081
          name: telemetry
        readinessProbe:
          httpGet:
            path: /
            port: 8081
          initialDelaySeconds: 5
          timeoutSeconds: 5
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
          runAsUser: 65534
      serviceAccountName: kube-state-metrics
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}
---
---
{{- if .Values.otelCollector.install }}
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: otel-collector
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app: opentelemetry
    component: otel-collector
  name: otel-collector
  namespace: kinetica-system
spec:
  minReadySeconds: 5
  progressDeadlineSeconds: 120
  replicas: 1
  selector:
    matchLabels:
      app: opentelemetry
      component: otel-collector
  template:
    metadata:
      annotations:
        prometheus.io/path: /metrics
        prometheus.io/port: '8889'
        prometheus.io/scrape: 'true'
      labels:
        app: opentelemetry
        component: otel-collector
    spec:
      containers:
      - command:
        - /otelcol-contrib
        - --config=/conf/otel-collector-config.yaml
        env:
        - name: GOGC
          value: '80'
        image: '{{ .Values.otelCollector.image.repository }}:{{ .Values.otelCollector.image.tag
          }}'
        livenessProbe:
          httpGet:
            path: /
            port: 13133
        name: otel-collector
        ports:
        - containerPort: 9601
        - containerPort: 4317
        - containerPort: 4318
        - containerPort: 8006
        - containerPort: 8889
        - containerPort: 55679
        readinessProbe:
          httpGet:
            path: /
            port: 13133
        resources:
          limits:
            cpu: 2000m
            memory: 4Gi
          requests:
            cpu: 1000m
            memory: 2Gi
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          seccompProfile:
            type: RuntimeDefault
        volumeMounts:
        - mountPath: /conf
          name: otel-collector-config-vol
      serviceAccountName: opentelemetry-collector
      volumes:
      - configMap:
          items:
          - key: otel-collector-config
            path: otel-collector-config.yaml
          name: otel-collector-conf
        name: otel-collector-config-vol
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}
---
{{- end }}