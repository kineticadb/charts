
{{- define "kinetica-operators.post-install-secret-patch" }}
{{- $licenseSecretName := .Values.kineticacluster.gpudbCluster.licenseSecretName | default "" -}}
{{- $adminUserSecretName := .Values.dbAdminUser.adminUserSecretName | default "" -}}
{{- $adminCreate := .Values.dbAdminUser.create -}}
{{- if and $adminCreate (eq $adminUserSecretName "") -}}
  {{- fail "dbAdminUser.adminUserSecretName is required when dbAdminUser.create is true. Create a secret with 'username' and 'password' keys. Example: kubectl create secret generic my-admin-secret --from-literal=username=kadmin --from-literal=password=YOUR_PASSWORD -n gpudb" -}}
{{- end -}}
{{- if or (ne $licenseSecretName "") (and $adminCreate (ne $adminUserSecretName "")) }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-patch-secrets-script
  namespace: {{ .Release.Namespace }}
  annotations:
    "helm.sh/hook": post-install,post-upgrade
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
    "helm.sh/hook-weight": "-10"
data:
  patch-secrets.sh: |
    #!/bin/sh
    set -e

    CLUSTER_NAME="{{ .Values.kineticacluster.name }}"
    CLUSTER_NS="{{ .Values.kineticacluster.namespace }}"
    RING_NAME="{{ .Values.kineticacluster.name }}"
    LICENSE_SECRET_NAME="{{ $licenseSecretName }}"
    ADMIN_SECRET_NAME="{{ $adminUserSecretName }}"

    # Read a key from a Kubernetes secret via kubectl (searches cluster namespace, then release namespace)
    read_secret_key() {
      _secret_name="$1"
      _key="$2"
      _val=""
      # Try cluster namespace first, then release namespace
      for _ns in "$CLUSTER_NS" "{{ .Release.Namespace }}"; do
        _val="$(kubectl get secret "$_secret_name" -n "$_ns" -o jsonpath="{.data.$_key}" 2>/dev/null || true)"
        if [ -n "$_val" ]; then
          printf '%s' "$_val" | base64 -d
          return 0
        fi
      done
      return 1
    }

    # Wait for a secret to appear (pre-install hooks may recreate the namespace, wiping pre-created secrets)
    wait_for_secret() {
      _secret_name="$1"
      _max_wait=300
      _elapsed=0
      while [ $_elapsed -lt $_max_wait ]; do
        for _ns in "$CLUSTER_NS" "{{ .Release.Namespace }}"; do
          if kubectl get secret "$_secret_name" -n "$_ns" >/dev/null 2>&1; then
            echo "Found secret '$_secret_name' in namespace '$_ns'"
            return 0
          fi
        done
        echo "Waiting for secret '$_secret_name' to appear... (${_elapsed}s/${_max_wait}s)"
        sleep 10
        _elapsed=$((_elapsed + 10))
      done
      echo "WARNING: Secret '$_secret_name' not found after ${_max_wait}s"
      return 1
    }

    json_escape() {
      printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
    }

    # 1. Patch license from secret
    if [ -n "$LICENSE_SECRET_NAME" ]; then
      wait_for_secret "$LICENSE_SECRET_NAME" || true
      LICENSE="$(read_secret_key "$LICENSE_SECRET_NAME" "license" || true)"
      if [ -n "$LICENSE" ]; then
        LICENSE="$(json_escape "$LICENSE")"
        echo "Patching KineticaCluster with license from secret..."
        kubectl patch kineticacluster "$CLUSTER_NAME" -n "$CLUSTER_NS" --type=merge \
          -p "{\"spec\":{\"gpudbCluster\":{\"license\":\"$LICENSE\"}}}"
      else
        echo "WARNING: Could not read 'license' key from secret '$LICENSE_SECRET_NAME'"
      fi
    fi

{{- if and $adminCreate (ne $adminUserSecretName "") }}
    # 2. Create admin-pwd secret from admin credentials secret
    if [ -n "$ADMIN_SECRET_NAME" ]; then
      wait_for_secret "$ADMIN_SECRET_NAME" || true
      PASSWORD="$(read_secret_key "$ADMIN_SECRET_NAME" "password" || true)"
      if [ -n "$PASSWORD" ]; then
        PASSWORD_B64=$(printf '%s' "$PASSWORD" | base64 | tr -d '\n')
        echo "Creating/updating admin-pwd secret..."
        cat <<EOSECRET | kubectl apply -f -
    apiVersion: v1
    kind: Secret
    metadata:
      name: admin-pwd
      namespace: $CLUSTER_NS
      labels:
        app.kubernetes.io/name: kinetica-operators
        app.kubernetes.io/managed-by: kinetica-operators-hook
    type: Opaque
    data:
      password: $PASSWORD_B64
    EOSECRET
      else
        echo "WARNING: Could not read 'password' key from secret '$ADMIN_SECRET_NAME'"
      fi

      # 3. Create admin KineticaUser
      USERNAME="$(read_secret_key "$ADMIN_SECRET_NAME" "username" || true)"
      if [ -n "$USERNAME" ]; then
        echo "Creating/updating admin KineticaUser '$USERNAME'..."
        cat <<EOUSER | kubectl apply -f -
    apiVersion: app.kinetica.com/v1
    kind: KineticaUser
    metadata:
      name: $USERNAME
      namespace: $CLUSTER_NS
      labels:
        app.kubernetes.io/name: kinetica-operators
        app.kubernetes.io/managed-by: kinetica-operators-hook
    spec:
      ringName: $RING_NAME
      uid: $USERNAME
      action: upsert
      reveal: true
      upsert:
        givenName: Admin
        displayName: "Admin Account"
        lastName: Account
        passwordSecret: admin-pwd
        userPrincipalName: admin@acct.com
    EOUSER

        # 4. Create user-specific KineticaGrant
        echo "Creating/updating admin KineticaGrant for '$USERNAME'..."
        cat <<EOGRANT | kubectl apply -f -
    apiVersion: app.kinetica.com/v1
    kind: KineticaGrant
    metadata:
      name: ${USERNAME}-global-admin-create
      namespace: $CLUSTER_NS
      labels:
        app.kubernetes.io/name: kinetica-operators
        app.kubernetes.io/managed-by: kinetica-operators-hook
    spec:
      ringName: $RING_NAME
      addGrantRoleRequest:
        role: global_admins
        member: $USERNAME
    EOGRANT
      else
        echo "WARNING: Could not read 'username' key from secret '$ADMIN_SECRET_NAME'"
      fi
    fi
{{- end }}

    echo "Post-install secret patching complete."
---
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Release.Name }}-post-install-secret-patch
  namespace: {{ .Release.Namespace }}
  labels:
    "app.kubernetes.io/name": "kinetica-operators"
    "app.kubernetes.io/managed-by": "Helm"
    "app.kubernetes.io/instance": "{{ .Release.Name }}"
    "helm.sh/chart": '{{ include "kinetica-operators.chart" . }}'
  annotations:
    "helm.sh/hook": post-install,post-upgrade
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
    "helm.sh/hook-weight": "-5"
spec:
  template:
    spec:
      serviceAccount: kineticacluster-operator
      serviceAccountName: kineticacluster-operator
      securityContext:
        fsGroup: 2000
        runAsGroup: 3000
        runAsNonRoot: true
        runAsUser: 65432
      volumes:
      - name: script-volume
        configMap:
          name: {{ .Release.Name }}-patch-secrets-script
      - name: tmp
        emptyDir: {}
      containers:
      - name: patch-secrets
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          seccompProfile:
            type: RuntimeDefault
        image: "{{ include "kinetica-operators.image" (dict "registry" (.Values.kineticacluster.supportingImages.busybox.registry | default .Values.global.image.registry) "repository" .Values.kineticacluster.supportingImages.busybox.repository "tag" .Values.kineticacluster.supportingImages.busybox.tag) }}"
        command: ["/bin/sh"]
        args: ["/mnt/scripts/patch-secrets.sh"]
        env:
        - name: HOME
          value: /tmp
        volumeMounts:
        - name: script-volume
          mountPath: /mnt/scripts
        - name: tmp
          mountPath: /tmp
      restartPolicy: Never
{{- end }}
{{- end }}
