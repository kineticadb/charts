
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

    # Read a key from the secret. Prefers a volume-mounted file at
    # /mnt/secrets/<mount_type>/<key> (populated by kubelet when the Job
    # references the secret in its pod spec — also the hook that signals
    # secret-distribution platforms like Palantir Rubix to auto-provision
    # the secret into the release namespace). Falls back to kubectl lookup
    # in the cluster namespace, then the release namespace.
    read_secret_key() {
      _secret_name="$1"
      _key="$2"
      _mount_type="$3"
      _val=""
      # Prefer volume-mounted secret
      if [ -n "$_mount_type" ] && [ -f "/mnt/secrets/$_mount_type/$_key" ]; then
        _val="$(cat "/mnt/secrets/$_mount_type/$_key" 2>/dev/null || true)"
        # Strip wrapping double quotes (some platforms store values quoted)
        _val="$(printf '%s' "$_val" | sed -e 's/^"//' -e 's/"$//')"
        if [ -n "$_val" ]; then
          printf '%s' "$_val"
          return 0
        fi
      fi
      # Fall back to kubectl lookup in cluster namespace, then release namespace
      for _ns in "$CLUSTER_NS" "{{ .Release.Namespace }}"; do
        _val="$(kubectl get secret "$_secret_name" -n "$_ns" -o jsonpath="{.data.$_key}" 2>/dev/null || true)"
        if [ -n "$_val" ]; then
          printf '%s' "$_val" | base64 -d
          return 0
        fi
      done
      return 1
    }

    # Wait briefly for a secret to become available. If the Job's pod has
    # the secret volume-mounted (Rubix / kubelet path), the expected key
    # file is present at pod start — skip polling entirely. Otherwise poll
    # kubectl for a short window to cover kubelet mount races and pre-
    # install-hook namespace rebuilds.
    #
    # The polling budget is intentionally short (30s) because if Apollo's
    # secret distribution isn't configured for this namespace, the secret
    # is never going to appear — long polling just consumes the Helm hook
    # timeout (default 300s) and turns "missing secret" into "Helm timed
    # out waiting for the condition", obscuring the real cause. Two waits
    # at 30s fit comfortably under the 300s Helm window with room left
    # for the rest of the script.
    wait_for_secret() {
      _secret_name="$1"
      _mount_type="$2"
      _expect_key="$3"
      # Short-circuit when the secret is already volume-mounted
      if [ -n "$_mount_type" ] && [ -f "/mnt/secrets/$_mount_type/$_expect_key" ]; then
        echo "Secret '$_secret_name' available via mounted volume at /mnt/secrets/$_mount_type"
        return 0
      fi
      _max_wait=30
      _elapsed=0
      while [ $_elapsed -lt $_max_wait ]; do
        for _ns in "$CLUSTER_NS" "{{ .Release.Namespace }}"; do
          if kubectl get secret "$_secret_name" -n "$_ns" >/dev/null 2>&1; then
            echo "Found secret '$_secret_name' in namespace '$_ns'"
            return 0
          fi
        done
        sleep 5
        _elapsed=$((_elapsed + 5))
      done
      echo "ERROR: secret '$_secret_name' not present in '$CLUSTER_NS' or '{{ .Release.Namespace }}', and not volume-mounted at /mnt/secrets/$_mount_type. Likely cause: Apollo secret distribution is not configured for this namespace, or the configured secret name does not match the chart value."
      return 1
    }

    json_escape() {
      printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
    }

    # 1. Patch license from secret
    if [ -n "$LICENSE_SECRET_NAME" ]; then
      wait_for_secret "$LICENSE_SECRET_NAME" "license" "license" || true
      LICENSE="$(read_secret_key "$LICENSE_SECRET_NAME" "license" "license" || true)"
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
      wait_for_secret "$ADMIN_SECRET_NAME" "admin" "password" || true
      PASSWORD="$(read_secret_key "$ADMIN_SECRET_NAME" "password" "admin" || true)"
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

      # 3. Create global-admins KineticaRole
      echo "Creating/updating global-admins KineticaRole..."
      cat <<EOROLE | kubectl apply -f -
    apiVersion: app.kinetica.com/v1
    kind: KineticaRole
    metadata:
      name: global-admins
      namespace: $CLUSTER_NS
      labels:
        app.kubernetes.io/name: kinetica-operators
        app.kubernetes.io/managed-by: kinetica-operators-hook
    spec:
      ringName: $RING_NAME
      role:
        name: "global_admins"
    EOROLE

      # 4. Create global-admin-system-admin KineticaGrant
      echo "Creating/updating global-admin-system-admin KineticaGrant..."
      cat <<EOGRANT_SYS | kubectl apply -f -
    apiVersion: app.kinetica.com/v1
    kind: KineticaGrant
    metadata:
      name: global-admin-system-admin
      namespace: $CLUSTER_NS
      labels:
        app.kubernetes.io/name: kinetica-operators
        app.kubernetes.io/managed-by: kinetica-operators-hook
    spec:
      ringName: $RING_NAME
      addGrantPermissionRequest:
        systemPermission:
          name: "global_admins"
          permission: "system_admin"
    EOGRANT_SYS

      # 5. Create admin KineticaUser
      USERNAME="$(read_secret_key "$ADMIN_SECRET_NAME" "username" "admin" || true)"
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

        # 6. Create user-specific KineticaGrant
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
{{- if ne $licenseSecretName "" }}
      # Referencing secretName here causes kubelet to mount the pre-created
      # secret into the pod at start, and signals secret-distribution
      # platforms (e.g. Palantir Rubix) to auto-provision the named secret
      # into the release namespace. optional: true lets the pod start even
      # if the secret is absent, so the script can fall back to kubectl.
      - name: license-secret
        secret:
          secretName: {{ $licenseSecretName }}
          optional: true
{{- end }}
{{- if and $adminCreate (ne $adminUserSecretName "") }}
      - name: admin-secret
        secret:
          secretName: {{ $adminUserSecretName }}
          optional: true
{{- end }}
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
{{- if ne $licenseSecretName "" }}
        - name: license-secret
          mountPath: /mnt/secrets/license
          readOnly: true
{{- end }}
{{- if and $adminCreate (ne $adminUserSecretName "") }}
        - name: admin-secret
          mountPath: /mnt/secrets/admin
          readOnly: true
{{- end }}
        - name: tmp
          mountPath: /tmp
      restartPolicy: Never
{{- end }}
{{- end }}
