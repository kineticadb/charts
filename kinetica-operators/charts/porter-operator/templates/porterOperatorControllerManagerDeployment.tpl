{{- define "porter-operator.deployment" }}
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    {{- include "porter-operator.labels" . | nindent 4 }}
    control-plane: controller-manager
  name: porter-operator-controller-manager
  namespace: {{ .Values.porterOperator.namespace  }}
spec:
  replicas: {{ .Values.porterOperator.replicas }}
  revisionHistoryLimit: 1
  selector:
    matchLabels:
      {{- include "porter-operator.selectorLabels" . | nindent 6 }}
  strategy:
    type: Recreate
  template:
    metadata:
      {{- with .Values.porterOperator.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "porter-operator.selectorLabels" . | nindent 8 }}
    spec:
      serviceAccountName: {{ include "porter-operator.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.porterOperator.podSecurityContext | nindent 8 }}
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - args:
            - '--secure-listen-address=0.0.0.0:{{ .Values.porterOperator.proxy.containerPort }}'
            - --upstream=http://127.0.0.1:8080/
            - --logtostderr=true
            - --v=10
          image: {{ .Values.porterOperator.proxy.image.repository }}:v{{ .Values.porterOperator.proxy.image.tag }}
          imagePullPolicy: {{ .Values.porterOperator.proxy.image.pullPolicy }}
          name: kube-rbac-proxy
          ports:
            - containerPort: {{ .Values.porterOperator.proxy.containerPort }}
              name: https
        - args:
            - '--health-probe-bind-address=:{{ .Values.porterOperator.manager.probePort }}'
            - --metrics-bind-address=127.0.0.1:8080
            - --leader-elect
          command:
            - /manager
          image: {{ .Values.porterOperator.manager.image.repository }}:v{{ .Values.porterOperator.manager.image.tag | default .Chart.AppVersion }}
          imagePullPolicy: {{ .Values.porterOperator.manager.image.pullPolicy }}
          livenessProbe:
            httpGet:
              path: /healthz
              port: {{ .Values.porterOperator.manager.probePort }}
            initialDelaySeconds: 15
            periodSeconds: 20
          name: manager
          readinessProbe:
            httpGet:
              path: /readyz
              port: {{ .Values.porterOperator.manager.probePort }}
            initialDelaySeconds: 5
            periodSeconds: 10
          resources:
            limits:
              cpu: 100m
              memory: 30Mi
            requests:
              cpu: 100m
              memory: 20Mi
          securityContext:
            allowPrivilegeEscalation: false
      terminationGracePeriodSeconds: 10
      {{- with .Values.porterOperator.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.porterOperator.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.porterOperator.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
---    
{{- end }}
