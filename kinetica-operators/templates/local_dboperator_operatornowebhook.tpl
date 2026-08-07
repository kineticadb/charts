{{- define "kinetica-operators.local-dboperator-operatornowebhook" }}

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: kineticaoperator-config-map
  namespace: '{{ .Release.Namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
data:
  {{- (tpl (.Files.Get "files/configmaps/local-dboperator-operatornowebhook-kineticaoperator-config-map.yaml") . | nindent 2)  }}

---
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    control-plane: controller-manager
  name: kineticaoperator-controller-manager-metrics-service
  namespace: '{{ .Release.Namespace }}'
spec:
  ports:
  - name: https
    port: 8443
    protocol: TCP
    targetPort: 8443
  selector:
    app.kubernetes.io/name: dboperator
    control-plane: controller-manager

---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
    control-plane: controller-manager
  name: kineticaoperator-controller-manager
  namespace: '{{ .Release.Namespace }}'
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
        app.kubernetes.io/name: dboperator
        control-plane: controller-manager
    spec:
      containers:
      - args:
        - --metrics-bind-address=:8443
        - --leader-elect
        - --health-probe-bind-address=:8081
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
        - name: ENABLE_WEBHOOKS
          value: 'false'
        image: '{{ include "kinetica-operators.image" (dict "registry" (.Values.dbOperator.image.registry
          | default .Values.global.image.registry) "repository" .Values.dbOperator.image.repository
          "tag" .Values.dbOperator.image.tag "digest" .Values.dbOperator.image.digest)
          }}'
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8081
          initialDelaySeconds: 120
          periodSeconds: 20
        name: manager
        ports: []
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
          readOnlyRootFilesystem: true
          runAsGroup: 65532
          runAsNonRoot: true
          runAsUser: 65532
          seccompProfile:
            type: RuntimeDefault
        volumeMounts:
        - mountPath: /etc/config/
          name: gpudb-tmpl
        - mountPath: /etc/manager/manager-config
          name: kineticaoperator-config-map
      securityContext:
        fsGroup: 65532
        runAsGroup: 65532
        runAsNonRoot: true
        runAsUser: 65532
        seccompProfile:
          type: RuntimeDefault
      serviceAccountName: '{{ .Values.dbOperator.serviceAccountName | default "controller-manager"
        }}'
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