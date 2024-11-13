{{- define "kinetica-operators.all-genai-operator" }}

---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/name: genai-operator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "genai-operator.chart" . }}'
  name: genai-operator-controller-manager
  namespace: kinetica-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  labels:
    app.kubernetes.io/name: genai-operator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "genai-operator.chart" . }}'
  name: genai-operator-leader-election-role
  namespace: kinetica-system
rules:
- apiGroups:
  - ''
  resources:
  - configmaps
  verbs:
  - get
  - list
  - watch
  - create
  - update
  - patch
  - delete
- apiGroups:
  - coordination.k8s.io
  resources:
  - leases
  verbs:
  - get
  - list
  - watch
  - create
  - update
  - patch
  - delete
- apiGroups:
  - ''
  resources:
  - events
  verbs:
  - create
  - patch

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: genai-operator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "genai-operator.chart" . }}'
  name: genai-operator-embeddingmodel-editor-role
rules:
- apiGroups:
  - genai.kinetica.com
  resources:
  - embeddingmodels
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - genai.kinetica.com
  resources:
  - embeddingmodels/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: genai-operator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "genai-operator.chart" . }}'
  name: genai-operator-embeddingmodel-viewer-role
rules:
- apiGroups:
  - genai.kinetica.com
  resources:
  - embeddingmodels
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - genai.kinetica.com
  resources:
  - embeddingmodels/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: genai-operator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "genai-operator.chart" . }}'
  name: genai-operator-languagemodel-editor-role
rules:
- apiGroups:
  - genai.kinetica.com
  resources:
  - languagemodels
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - genai.kinetica.com
  resources:
  - languagemodels/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: genai-operator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "genai-operator.chart" . }}'
  name: genai-operator-languagemodel-viewer-role
rules:
- apiGroups:
  - genai.kinetica.com
  resources:
  - languagemodels
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - genai.kinetica.com
  resources:
  - languagemodels/status
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: genai-operator-manager-role
  labels:
    app.kubernetes.io/name: genai-operator
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "genai-operator.chart" . }}'
rules:
- apiGroups:
  - ''
  resources:
  - configmaps
  - events
  - namespaces
  - nodes
  - persistentvolumeclaims
  - persistentvolumes
  - pods
  - secrets
  - services
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - ''
  resources:
  - configmaps/status
  - events/status
  - namespaces/status
  - nodes/status
  - persistentvolumeclaims/status
  - persistentvolumes/status
  - pods/status
  - secrets/status
  - services/status
  verbs:
  - get
  - patch
  - update
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusters
  verbs:
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - app.kinetica.com
  resources:
  - kineticaclusters/status
  verbs:
  - get
  - patch
  - update
- apiGroups:
  - apps
  resources:
  - daemonsets
  - deployments
  - statefulsets
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - apps
  resources:
  - daemonsets/status
  - deployments/status
  - statefulsets/status
  verbs:
  - get
  - patch
  - update
- apiGroups:
  - genai.kinetica.com
  resources:
  - embeddingmodels
  - languagemodels
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
- apiGroups:
  - genai.kinetica.com
  resources:
  - embeddingmodels/finalizers
  - languagemodels/finalizers
  verbs:
  - update
- apiGroups:
  - genai.kinetica.com
  resources:
  - embeddingmodels/status
  - languagemodels/status
  verbs:
  - get
  - patch
  - update

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: genai-operator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "genai-operator.chart" . }}'
  name: genai-operator-metrics-reader
rules:
- nonResourceURLs:
  - /metrics
  verbs:
  - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/name: genai-operator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "genai-operator.chart" . }}'
  name: genai-operator-proxy-role
rules:
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

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    app.kubernetes.io/name: genai-operator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "genai-operator.chart" . }}'
  name: genai-operator-leader-election-rolebinding
  namespace: kinetica-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: genai-operator-leader-election-role
subjects:
- kind: ServiceAccount
  name: genai-operator-controller-manager
  namespace: kinetica-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app.kubernetes.io/name: genai-operator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "genai-operator.chart" . }}'
  name: genai-operator-manager-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: genai-operator-manager-role
subjects:
- kind: ServiceAccount
  name: genai-operator-controller-manager
  namespace: kinetica-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app.kubernetes.io/name: genai-operator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "genai-operator.chart" . }}'
  name: genai-operator-proxy-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: genai-operator-proxy-role
subjects:
- kind: ServiceAccount
  name: genai-operator-controller-manager
  namespace: kinetica-system

---
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/name: genai-operator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "genai-operator.chart" . }}'
    control-plane: controller-manager
  name: genai-operator-controller-manager-metrics-service
  namespace: kinetica-system
spec:
  ports:
  - name: https
    port: 8443
    protocol: TCP
    targetPort: https
  selector:
    control-plane: controller-manager

---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: genai-operator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "genai-operator.chart" . }}'
    control-plane: controller-manager
  name: genai-operator-controller-manager
  namespace: kinetica-system
spec:
  replicas: 1
  selector:
    matchLabels:
      control-plane: controller-manager
  template:
    metadata:
      annotations:
        kubectl.kubernetes.io/default-container: manager
      labels:
        control-plane: controller-manager
    spec:
      containers:
      - args:
        - --secure-listen-address=0.0.0.0:8443
        - --upstream=http://127.0.0.1:8080/
        - --logtostderr=true
        - --v=0
        image: '{{ .Values.kubeRbacProxy.image.repository }}:{{ .Values.kubeRbacProxy.image.tag
          }}'
        name: kube-rbac-proxy
        ports:
        - containerPort: 8443
          name: https
          protocol: TCP
        resources:
          limits:
            cpu: 500m
            memory: 128Mi
          requests:
            cpu: 5m
            memory: 64Mi
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
      - args:
        - --health-probe-bind-address=:8081
        - --metrics-bind-address=127.0.0.1:8080
        - --leader-elect
        command:
        - /manager
        image: '{{- if .Values.image.repository -}}{{- .Values.image.repository -}}{{-
          else -}}{{- .Values.image.registry -}}/{{- .Values.image.image -}}{{- end
          -}}{{- if (.Values.image.digest) -}} @{{- .Values.image.digest -}}{{- else
          -}}:{{- .Values.image.tag -}}{{- end -}}'
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8081
          initialDelaySeconds: 15
          periodSeconds: 20
        name: manager
        readinessProbe:
          httpGet:
            path: /readyz
            port: 8081
          initialDelaySeconds: 5
          periodSeconds: 10
        resources:
          limits:
            cpu: 500m
            memory: 128Mi
          requests:
            cpu: 10m
            memory: 64Mi
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
        env:
        - name: GENAI_OPERATOR_NO_GPU
          value: '{{ default "false" .Values.noGpuMode }}'
      securityContext:
        runAsNonRoot: true
        runAsUser: 65432
      serviceAccountName: genai-operator-controller-manager
      terminationGracePeriodSeconds: 10
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