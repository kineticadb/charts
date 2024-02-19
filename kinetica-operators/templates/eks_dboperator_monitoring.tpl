{{- define "kinetica-operators.eks-dboperator-monitoring" }}

---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    k8s-app: cwagent
  name: cwagent-prometheus
  namespace: amazon-cloudwatch

---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    k8s-app: fluent-bit
  name: fluent-bit
  namespace: amazon-cloudwatch

---
{{- if .Values.kubeStateMetrics.install }}
apiVersion: v1
automountServiceAccountToken: false
kind: ServiceAccount
metadata:
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    app.kubernetes.io/component: exporter
    app.kubernetes.io/name: kube-state-metrics
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
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    k8s-app: cwagent
  name: cwagent-prometheus-role
rules:
- apiGroups:
  - ''
  resources:
  - nodes
  - nodes/proxy
  - services
  - endpoints
  - pods
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs:
  - get
  - list
  - watch
- nonResourceURLs:
  - /metrics
  verbs:
  - get
- apiGroups:
  - ''
  resourceNames:
  - cwagent-clusterleader
  resources:
  - configmaps
  verbs:
  - get
  - update

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    k8s-app: fluent-bit
  name: fluent-bit-role
rules:
- nonResourceURLs:
  - /metrics
  verbs:
  - get
- apiGroups:
  - ''
  resources:
  - namespaces
  - pods
  - pods/logs
  verbs:
  - get
  - list
  - watch

---
{{- if .Values.kubeStateMetrics.install }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    app.kubernetes.io/component: exporter
    app.kubernetes.io/name: kube-state-metrics
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
---
{{- if .Values.otelCollector.install }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: otel-collector-role
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    app.kubernetes.io/name: otel-collector
rules:
- apiGroups:
  - '*'
  resources:
  - '*'
  verbs:
  - '*'
{{- end }}
---
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    k8s-app: cwagent
  name: cwagent-prometheus-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cwagent-prometheus-role
subjects:
- kind: ServiceAccount
  name: cwagent-prometheus
  namespace: amazon-cloudwatch

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    k8s-app: fluent-bit
  name: fluent-bit-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: fluent-bit-role
subjects:
- kind: ServiceAccount
  name: fluent-bit
  namespace: amazon-cloudwatch

---
{{- if .Values.kubeStateMetrics.install }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    app.kubernetes.io/component: exporter
    app.kubernetes.io/name: kube-state-metrics
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
---
{{- if .Values.otelCollector.install }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: otel-collector-role-binding
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    app.kubernetes.io/name: otel-collector
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: otel-collector-role
subjects:
- kind: ServiceAccount
  name: opentelemetry-collector
  namespace: kinetica-system
{{- end }}
---
---
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    k8s-app: fluent-bit
  name: fluent-bit-cluster-info
  namespace: amazon-cloudwatch
data:
  {{- (tpl (.Files.Get "files/configmaps/eks-dboperator-monitoring-fluent-bit-cluster-info.yaml") . | nindent 2)  }}

---
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    k8s-app: fluent-bit
  name: fluent-bit-config
  namespace: amazon-cloudwatch
data:
  {{- (tpl (.Files.Get "files/configmaps/eks-dboperator-monitoring-fluent-bit-config.yaml") . | nindent 2)  }}

---
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    k8s-app: cwagent
  name: prometheus-config
  namespace: amazon-cloudwatch
data:
  {{ (.Files.Glob "files/configmaps/eks-dboperator-monitoring-prometheus-config.yaml").AsConfig }}

---
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    k8s-app: cwagent
  name: prometheus-cwagentconfig
  namespace: amazon-cloudwatch
data:
  {{- (tpl (.Files.Get "files/configmaps/eks-dboperator-monitoring-prometheus-cwagentconfig.yaml") . | nindent 2)  }}

---
{{- if .Values.otelCollector.install }}
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app: opentelemetry
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    component: otel-collector-conf
    app.kubernetes.io/name: otel-collector
  name: otel-collector-conf
  namespace: kinetica-system
data:
  {{ (.Files.Glob "files/configmaps/eks-dboperator-monitoring-otel-collector-conf.yaml").AsConfig }}
{{- end }}
---
---
{{- if .Values.kubeStateMetrics.install }}
apiVersion: v1
kind: Service
metadata:
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    app.kubernetes.io/component: exporter
    app.kubernetes.io/name: kube-state-metrics
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
    app: opentelemetry
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    component: otel-collector
    app.kubernetes.io/name: otel-collector
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
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    app.kubernetes.io/component: exporter
    app.kubernetes.io/name: kube-state-metrics
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
    app: opentelemetry
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    component: otel-collector
    app.kubernetes.io/name: otel-collector
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
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    k8s-app: cwagent
  name: cloudwatch-agent
  namespace: amazon-cloudwatch
spec:
  selector:
    matchLabels:
      k8s-app: cwagent
      name: cloudwatch-agent
  template:
    metadata:
      labels:
        k8s-app: cwagent
        name: cloudwatch-agent
    spec:
      containers:
      - env:
        - name: HOST_IP
          valueFrom:
            fieldRef:
              fieldPath: status.hostIP
        - name: HOST_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: K8S_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: CI_VERSION
          value: k8s/1.3.8
        image: '{{ .Values.cloudwatchAgent.image.repository }}:{{ .Values.cloudwatchAgent.image.tag
          }}'
        name: cloudwatch-agent
        resources:
          limits:
            cpu: 200m
            memory: 200Mi
          requests:
            cpu: 200m
            memory: 200Mi
        volumeMounts:
        - mountPath: /etc/cwagentconfig
          name: prometheus-cwagentconfig
        - mountPath: /etc/prometheusconfig
          name: prometheus-config
        - mountPath: /rootfs
          name: rootfs
          readOnly: true
        - mountPath: /var/run/docker.sock
          name: dockersock
          readOnly: true
        - mountPath: /var/lib/docker
          name: varlibdocker
          readOnly: true
        - mountPath: /run/containerd/containerd.sock
          name: containerdsock
          readOnly: true
        - mountPath: /sys
          name: sys
          readOnly: true
        - mountPath: /dev/disk
          name: devdisk
          readOnly: true
      serviceAccountName: cwagent-prometheus
      terminationGracePeriodSeconds: 60
      volumes:
      - configMap:
          name: prometheus-cwagentconfig
        name: prometheus-cwagentconfig
      - configMap:
          name: prometheus-config
        name: prometheus-config
      - hostPath:
          path: /
        name: rootfs
      - hostPath:
          path: /var/run/docker.sock
        name: dockersock
      - hostPath:
          path: /var/lib/docker
        name: varlibdocker
      - hostPath:
          path: /run/containerd/containerd.sock
        name: containerdsock
      - hostPath:
          path: /sys
        name: sys
      - hostPath:
          path: /dev/disk/
        name: devdisk

---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    app: kinetica-operators
    heritage: Helm
    release: '{{ .Release.Name }}'
    chart: '{{ include "kinetica-operators.chart" . }}'
    k8s-app: fluent-bit
    kubernetes.io/cluster-service: 'true'
    version: v1
  name: fluent-bit
  namespace: amazon-cloudwatch
spec:
  selector:
    matchLabels:
      k8s-app: fluent-bit
  template:
    metadata:
      labels:
        k8s-app: fluent-bit
        kubernetes.io/cluster-service: 'true'
        version: v1
    spec:
      containers:
      - env:
        - name: AWS_REGION
          valueFrom:
            configMapKeyRef:
              key: logs.region
              name: fluent-bit-cluster-info
        - name: CLUSTER_NAME
          valueFrom:
            configMapKeyRef:
              key: cluster.name
              name: fluent-bit-cluster-info
        - name: HTTP_SERVER
          valueFrom:
            configMapKeyRef:
              key: http.server
              name: fluent-bit-cluster-info
        - name: HTTP_PORT
          valueFrom:
            configMapKeyRef:
              key: http.port
              name: fluent-bit-cluster-info
        - name: READ_FROM_HEAD
          valueFrom:
            configMapKeyRef:
              key: read.head
              name: fluent-bit-cluster-info
        - name: READ_FROM_TAIL
          valueFrom:
            configMapKeyRef:
              key: read.tail
              name: fluent-bit-cluster-info
        - name: HOST_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: CI_VERSION
          value: k8s/1.3.8
        image: '{{ .Values.fluentBit.image.repository }}:{{ .Values.fluentBit.image.tag
          }}'
        imagePullPolicy: Always
        name: fluent-bit
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 500m
            memory: 100Mi
        volumeMounts:
        - mountPath: /var/fluent-bit/state
          name: fluentbitstate
        - mountPath: /var/log
          name: varlog
          readOnly: true
        - mountPath: /var/lib/docker/containers
          name: varlibdockercontainers
          readOnly: true
        - mountPath: /fluent-bit/etc/
          name: fluent-bit-config
        - mountPath: /run/log/journal
          name: runlogjournal
          readOnly: true
        - mountPath: /var/log/dmesg
          name: dmesg
          readOnly: true
      serviceAccountName: fluent-bit
      terminationGracePeriodSeconds: 10
      tolerations:
      - effect: NoSchedule
        key: node-role.kubernetes.io/master
        operator: Exists
      - effect: NoExecute
        operator: Exists
      - operator: Exists
      volumes:
      - hostPath:
          path: /var/fluent-bit/state
        name: fluentbitstate
      - hostPath:
          path: /var/log
        name: varlog
      - hostPath:
          path: /var/lib/docker/containers
        name: varlibdockercontainers
      - configMap:
          name: fluent-bit-config
        name: fluent-bit-config
      - hostPath:
          path: /run/log/journal
        name: runlogjournal
      - hostPath:
          path: /var/log/dmesg
        name: dmesg

{{- end }}