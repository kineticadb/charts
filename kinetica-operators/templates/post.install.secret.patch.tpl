
{{- define "kinetica-operators.post-install-secret-patch" }}
{{- $licenseSecretName := .Values.kineticacluster.gpudbCluster.licenseSecretName | default "" -}}
{{- $adminUserSecretName := .Values.dbAdminUser.adminUserSecretName | default "" -}}
{{- if or (ne $licenseSecretName "") (ne $adminUserSecretName "") }}
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
    ADMIN_PLACEHOLDER="{{ .Values.dbAdminUser.name }}"
    RING_NAME="{{ .Values.kineticacluster.name }}"

    # Helper: escape a value for safe embedding in JSON strings
    # Strip wrapping double quotes from a value (platform may store values quoted)
    strip_quotes() {
      printf '%s' "$1" | sed -e 's/^"//' -e 's/"$//'
    }

    json_escape() {
      printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
    }

    # 1. Patch license from mounted secret
    if [ -f /mnt/secrets/license/license ]; then
      LICENSE=$(strip_quotes "$(cat /mnt/secrets/license/license)")
      LICENSE=$(json_escape "$LICENSE")
      if [ -n "$LICENSE" ]; then
        echo "Patching KineticaCluster with license from secret..."
        kubectl patch kineticacluster "$CLUSTER_NAME" -n "$CLUSTER_NS" --type=merge \
          -p "{\"spec\":{\"gpudbCluster\":{\"license\":\"$LICENSE\"}}}"
      fi
    fi

    # 2. Patch admin password from mounted secret (use base64 to avoid JSON escaping issues)
    if [ -f /mnt/secrets/admin/password ]; then
      PASSWORD=$(strip_quotes "$(cat /mnt/secrets/admin/password)")
      PASSWORD_B64=$(printf '%s' "$PASSWORD" | base64 | tr -d '\n')
      if [ -n "$PASSWORD_B64" ]; then
        echo "Patching admin-pwd secret with password..."
        kubectl patch secret admin-pwd -n "$CLUSTER_NS" --type=merge \
          -p "{\"data\":{\"password\":\"$PASSWORD_B64\"}}"
      fi
    fi

    # 3. Handle admin username from mounted secret
    if [ -f /mnt/secrets/admin/username ]; then
      USERNAME=$(strip_quotes "$(cat /mnt/secrets/admin/username)")
      if [ -n "$USERNAME" ] && [ "$USERNAME" != "$ADMIN_PLACEHOLDER" ]; then
        echo "Admin username differs from placeholder, recreating user resources..."
        # Delete placeholder KineticaUser and user-specific KineticaGrant
        if [ -n "$ADMIN_PLACEHOLDER" ]; then
          kubectl delete kineticauser "$ADMIN_PLACEHOLDER" -n "$CLUSTER_NS" --ignore-not-found --wait=false
          kubectl delete kineticagrant "${ADMIN_PLACEHOLDER}-global-admin-create" -n "$CLUSTER_NS" --ignore-not-found --wait=false
        fi
        # Create KineticaUser with real username
        printf '%s\n' \
          "apiVersion: app.kinetica.com/v1" \
          "kind: KineticaUser" \
          "metadata:" \
          "  name: $USERNAME" \
          "  namespace: $CLUSTER_NS" \
          "spec:" \
          "  ringName: $RING_NAME" \
          "  uid: $USERNAME" \
          "  action: upsert" \
          "  reveal: true" \
          "  upsert:" \
          "    givenName: Admin" \
          '    displayName: "Admin Account"' \
          "    lastName: Account" \
          "    passwordSecret: admin-pwd" \
          "    userPrincipalName: admin@acct.com" \
          > /tmp/kineticauser.yaml
        kubectl apply -f /tmp/kineticauser.yaml
        # Create user-specific KineticaGrant
        printf '%s\n' \
          "apiVersion: app.kinetica.com/v1" \
          "kind: KineticaGrant" \
          "metadata:" \
          "  name: ${USERNAME}-global-admin-create" \
          "  namespace: $CLUSTER_NS" \
          "spec:" \
          "  ringName: $RING_NAME" \
          "  addGrantRoleRequest:" \
          "    role: global_admins" \
          "    member: $USERNAME" \
          > /tmp/kineticagrant.yaml
        kubectl apply -f /tmp/kineticagrant.yaml
      fi
    fi

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
      - name: license-secret
        secret:
          secretName: {{ $licenseSecretName }}
{{- end }}
{{- if ne $adminUserSecretName "" }}
      - name: admin-secret
        secret:
          secretName: {{ $adminUserSecretName }}
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
{{- if ne $adminUserSecretName "" }}
        - name: admin-secret
          mountPath: /mnt/secrets/admin
          readOnly: true
{{- end }}
        - name: tmp
          mountPath: /tmp
      restartPolicy: Never
{{- end }}
{{- end }}
