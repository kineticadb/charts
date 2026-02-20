{{- define "kinetica-operators.all-wboperator-operator" }}

---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    control-plane: controller-manager
  name: workbench-operator-controller-manager
  namespace: '{{ .Release.Namespace }}'
spec:
  replicas: 1
  selector:
    matchLabels:
      control-plane: controller-manager
  template:
    metadata:
      labels:
        control-plane: controller-manager
    spec:
      containers:
      - args:
        - --secure-listen-address=0.0.0.0:8443
        - --upstream=http://127.0.0.1:8080/
        - --logtostderr=true
        - --v=10
        image: '{{ .Values.kubeRbacProxy.image.repository }}:{{ .Values.kubeRbacProxy.image.tag
          }}'
        name: kube-rbac-proxy
        ports:
        - containerPort: 8443
          name: https
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          seccompProfile:
            type: RuntimeDefault
      - args:
        - --metrics-addr=127.0.0.1:8080
        - --enable-leader-election
        command:
        - /manager
        env:
        - name: WATCH_NAMESPACE
          value: '{{ .Values.kineticacluster.namespace }}'
        image: '{{ include "kinetica-operators.image" (dict "registry" .Values.global.image.registry
          "repository" .Values.wbOperator.image.repository "tag" .Values.wbOperator.image.tag
          "digest" .Values.wbOperator.image.digest) }}'
        name: manager
        resources:
          limits:
            cpu: 100m
            memory: 256Mi
          requests:
            cpu: 100m
            memory: 256Mi
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          runAsNonRoot: true
          seccompProfile:
            type: RuntimeDefault
        volumeMounts:
        - mountPath: /etc/config/
          name: workbench-tmpl
      securityContext:
        fsGroup: 2000
        runAsGroup: 3000
        runAsNonRoot: true
        runAsUser: 65432
      serviceAccountName: workbench-operator-service-account
      terminationGracePeriodSeconds: 10
      volumes:
      - configMap:
          name: workbench-tmpl
        name: workbench-tmpl
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