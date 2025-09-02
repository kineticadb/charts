{{- define "kinetica-operators.eks-dboperator-operator" }}

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: kineticaoperator-config-map
  namespace: kinetica-system
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
data:
  {{ (.Files.Glob "files/configmaps/eks-dboperator-operator-kineticaoperator-config-map.yaml").AsConfig }}

---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: kineticaoperator-controller-manager
    app.kubernetes.io/managed-by: Porter
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    app: gpudb
    app.kinetica.com/pool: infra
    app.kubernetes.io/component: db-operator
    app.kubernetes.io/part-of: kinetica
    component: kineticaoperator-controller-manager
    control-plane: controller-manager
  name: kineticaoperator-controller-manager
  namespace: kinetica-system
spec:
  replicas: 1
  selector:
    matchLabels:
      control-plane: controller-manager
  template:
    metadata:
      labels:
        app: gpudb
        app.kinetica.com/pool: infra
        app.kubernetes.io/component: db-operator
        app.kubernetes.io/name: kineticaoperator-controller-manager
        app.kubernetes.io/part-of: kinetica
        component: kineticaoperator-controller-manager
        control-plane: controller-manager
    spec:
      containers:
      - args:
        - --secure-listen-address=0.0.0.0:8443
        - --upstream=http://127.0.0.1:8080/
        - --v=0
        image: '{{ .Values.kubeRbacProxy.image.repository }}:{{ .Values.kubeRbacProxy.image.tag
          }}'
        imagePullPolicy: IfNotPresent
        name: kube-rbac-proxy
        ports:
        - containerPort: 8443
          name: https
        securityContext:
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
        - --zap-log-level=error
        command:
        - /manager
        env:
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: POD_SERVICE_ACCOUNT
          valueFrom:
            fieldRef:
              fieldPath: spec.serviceAccountName
        image: '{{- if .Values.dbOperator.image.repository -}}{{- .Values.dbOperator.image.repository
          -}}{{- else }}{{- .Values.dbOperator.image.registry -}}/{{- .Values.dbOperator.image.image
          -}}{{- end -}}{{- if (.Values.dbOperator.image.digest) -}} @{{- .Values.dbOperator.image.digest
          -}}{{- else -}}:{{- .Values.dbOperator.image.tag -}}{{- end -}}'
        imagePullPolicy: IfNotPresent
        name: manager
        resources:
          limits:
            cpu: 250m
            memory: 1Gi
          requests:
            cpu: 100m
            memory: 256Mi
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
        - mountPath: /etc/config/
          name: gpudb-tmpl
        - mountPath: /etc/manager/manager-config
          name: kineticaoperator-config-map
      securityContext:
        fsGroup: 2000
        runAsGroup: 3000
        runAsNonRoot: true
        runAsUser: 65432
      serviceAccountName: kineticacluster-operator
      terminationGracePeriodSeconds: 10
      volumes:
      - configMap:
          name: gpudb-tmpl
        name: gpudb-tmpl
      - configMap:
          name: kineticaoperator-config-map
        name: kineticaoperator-config-map
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