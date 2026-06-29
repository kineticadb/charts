{{- define "kinetica-operators.local-dboperator-operator" }}

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
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-webhook-service
  namespace: '{{ .Release.Namespace }}'
spec:
  ports:
  - port: 443
    protocol: TCP
    targetPort: 9443
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
      app.kubernetes.io/name: dboperator
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
        - --metrics-cert-path=/tmp/k8s-metrics-server/metrics-certs
        - --webhook-cert-path=/tmp/k8s-webhook-server/serving-certs
        command:
        - /manager
        image: '{{ include "kinetica-operators.image" (dict "registry" .Values.global.image.registry
          "repository" .Values.dbOperator.image.repository "tag" .Values.dbOperator.image.tag
          "digest" .Values.dbOperator.image.digest) }}'
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8081
          initialDelaySeconds: 120
          periodSeconds: 20
        name: manager
        ports:
        - containerPort: 9443
          name: webhook-server
          protocol: TCP
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
        volumeMounts:
        - mountPath: /tmp/k8s-metrics-server/metrics-certs
          name: metrics-certs
          readOnly: true
        - mountPath: /tmp/k8s-webhook-server/serving-certs
          name: webhook-certs
          readOnly: true
      securityContext:
        runAsNonRoot: true
        seccompProfile:
          type: RuntimeDefault
      serviceAccountName: controller-manager
      terminationGracePeriodSeconds: 10
      volumes:
      - name: metrics-certs
        secret:
          items:
          - key: ca.crt
            path: ca.crt
          - key: tls.crt
            path: tls.crt
          - key: tls.key
            path: tls.key
          optional: false
          secretName: metrics-server-cert
      - name: webhook-certs
        secret:
          secretName: webhook-server-cert
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

---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-metrics-certs
  namespace: '{{ .Release.Namespace }}'
spec:
  dnsNames:
  - kineticaoperator-controller-manager-metrics-service.kinetica-system.svc
  - kineticaoperator-controller-manager-metrics-service.kinetica-system.svc.cluster.local
  issuerRef:
    kind: Issuer
    name: kineticaoperator-selfsigned-issuer
  secretName: metrics-server-cert

---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-serving-cert
  namespace: '{{ .Release.Namespace }}'
spec:
  dnsNames:
  - kineticaoperator-webhook-service.kinetica-system.svc
  - kineticaoperator-webhook-service.kinetica-system.svc.cluster.local
  issuerRef:
    kind: Issuer
    name: kineticaoperator-selfsigned-issuer
  secretName: webhook-server-cert

---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  labels:
    app.kubernetes.io/name: dboperator
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  name: kineticaoperator-selfsigned-issuer
  namespace: '{{ .Release.Namespace }}'
spec:
  selfSigned: {}

---
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
metadata:
  annotations:
    cert-manager.io/inject-ca-from: kinetica-system/kineticaoperator-serving-cert
  name: kineticaoperator-mutating-webhook-configuration
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
webhooks:
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticacluster
  failurePolicy: Fail
  name: mkineticacluster-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusters
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticaclusteradmin
  failurePolicy: Fail
  name: mkineticaclusteradmin-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusteradmins
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticaclusterbackup
  failurePolicy: Fail
  name: mkineticaclusterbackup-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusterbackups
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticaclusterelasticity
  failurePolicy: Fail
  name: mkineticaclusterelasticity-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusterelasticities
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticaclusterresourcegroup
  failurePolicy: Fail
  name: mkineticaclusterresourcegroup-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusterresourcegroups
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticaclusterrestore
  failurePolicy: Fail
  name: mkineticaclusterrestore-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusterrestores
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticaclusterschema
  failurePolicy: Fail
  name: mkineticaclusterschema-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusterschemas
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticagrant
  failurePolicy: Fail
  name: mkineticagrant-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticagrants
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticareleaseversion
  failurePolicy: Fail
  name: mkineticareleaseversion-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticareleaseversions
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticarole
  failurePolicy: Fail
  name: mkineticarole-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaroles
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /mutate-app-kinetica-com-v1-kineticauser
  failurePolicy: Fail
  name: mkineticauser-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticausers
  sideEffects: None

---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  annotations:
    cert-manager.io/inject-ca-from: kinetica-system/kineticaoperator-serving-cert
  name: kineticaoperator-validating-webhook-configuration
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
webhooks:
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticacluster
  failurePolicy: Fail
  name: vkineticacluster-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusters
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticaclusteradmin
  failurePolicy: Fail
  name: vkineticaclusteradmin-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusteradmins
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticaclusterbackup
  failurePolicy: Fail
  name: vkineticaclusterbackup-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusterbackups
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticaclusterelasticity
  failurePolicy: Fail
  name: vkineticaclusterelasticity-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusterelasticities
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticaclusterresourcegroup
  failurePolicy: Fail
  name: vkineticaclusterresourcegroup-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusterresourcegroups
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticaclusterrestore
  failurePolicy: Fail
  name: vkineticaclusterrestore-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusterrestores
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticaclusterschema
  failurePolicy: Fail
  name: vkineticaclusterschema-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaclusterschemas
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticagrant
  failurePolicy: Fail
  name: vkineticagrant-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticagrants
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticareleaseversion
  failurePolicy: Fail
  name: vkineticareleaseversion-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticareleaseversions
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticarole
  failurePolicy: Fail
  name: vkineticarole-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticaroles
  sideEffects: None
- admissionReviewVersions:
  - v1
  clientConfig:
    service:
      name: kineticaoperator-webhook-service
      namespace: kinetica-system
      path: /validate-app-kinetica-com-v1-kineticauser
  failurePolicy: Fail
  name: vkineticauser-v1.kb.io
  rules:
  - apiGroups:
    - app.kinetica.com
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - kineticausers
  sideEffects: None

{{- end }}