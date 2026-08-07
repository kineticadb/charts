{{- define "kinetica-operators.crds" }}
{{- /* The upsert Job runs as the operator SA (defined in all_dboperator_rbac.tpl
       as a pre-install hook, weight -10) unless upsertKineticaCrds.serviceAccountName
       overrides it. When that override names a DIFFERENT SA than the operator's,
       the chart creates it here so the knob stays self-sufficient; when the two
       resolve to the same name, all_dboperator_rbac.tpl already defines it and a
       second document would collide. */}}
{{- $operatorSA := .Values.dbOperator.serviceAccountName | default "controller-manager" }}
{{- $upsertSA := .Values.upsertKineticaCrds.serviceAccountName | default $operatorSA }}
{{- if ne $upsertSA $operatorSA }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: '{{ $upsertSA }}'
  namespace: '{{ .Release.Namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  annotations:
    helm.sh/hook: pre-install
    helm.sh/hook-delete-policy: before-hook-creation
    helm.sh/hook-weight: '-10'
{{- end }}

---
apiVersion: batch/v1
kind: Job
metadata:
  name: '{{ .Release.Name }}-upsert-kinetica-crds'
  namespace: '{{ .Release.Namespace }}'
  labels:
    app.kubernetes.io/name: kinetica-operators
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: '{{ .Release.Name }}'
    helm.sh/chart: '{{ include "kinetica-operators.chart" . }}'
  annotations:
    helm.sh/hook: pre-install,pre-upgrade
    helm.sh/hook-delete-policy: before-hook-creation
    helm.sh/hook-weight: '-5'
spec:
  # 20-minute log-inspection window, then K8s TTL controller deletes the Job.
  ttlSecondsAfterFinished: 1200
  backoffLimit: 3
  template:
    metadata:
      labels:
        app.kubernetes.io/name: kinetica-operators
        app.kubernetes.io/instance: '{{ .Release.Name }}'
    spec:
      serviceAccountName: '{{ .Values.upsertKineticaCrds.serviceAccountName | default .Values.dbOperator.serviceAccountName | default "controller-manager" }}'
      securityContext:
        runAsNonRoot: true
        runAsUser: 65432
        fsGroup: 2000
      containers:
      - name: upsert-kinetica-crds-job
        image: "{{ include "kinetica-operators.image" (dict "registry" .Values.global.image.registry "repository" .Values.upsertKineticaCrds.image.repository "tag" .Values.upsertKineticaCrds.image.tag) }}"
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            drop:
            - ALL
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          seccompProfile:
            type: RuntimeDefault
        command: ["/bin/bash", "-c"]
        args:
          - |
            set -e
            echo "=== Starting CRD replacements ==="
            FAILED=0
            REPLACED=0
            SKIPPED=0
            for F in /crds/db-crds/* /crds/wb-crds/*; do
              if [ -f "$F" ]; then
                CRD_NAME=$(grep -m1 '^  name:' "$F" | awk '{print $2}')
                # Only a genuine NotFound counts as absent; any other get failure
                # (Forbidden, timeout, ...) must fail loudly, not masquerade as a skip.
                if ! ERR="$(kubectl get crd "$CRD_NAME" 2>&1)"; then
                  if printf '%s' "$ERR" | grep -qi 'NotFound'; then
                    echo "Skipping (not present): $F"
                    SKIPPED=$((SKIPPED + 1))
                    continue
                  fi
                  printf 'FAILED existence check %s: %s\n' "$CRD_NAME" "$(printf '%s' "$ERR" | head -1)"
                  FAILED=$((FAILED + 1))
                  continue
                fi
                echo "Processing: $F"
                if ERR="$(kubectl replace -f "$F" 2>&1)"; then
                  echo "  SUCCESS: $F - ${CRD_NAME}"
                  REPLACED=$((REPLACED + 1))
                else
                  printf 'FAILED %s: %s\n' "$CRD_NAME" "$(printf '%s' "$ERR" | head -1)"
                  FAILED=$((FAILED + 1))
                fi
              fi
            done
            echo ""
            echo "=== CRD replacement complete ==="
            if [ $FAILED -gt 0 ]; then
              echo "WARNING: $FAILED CRD(s) failed to update"
{{- if ne (.Values.upsertKineticaCrds.failOnError | toString) "false" }}
              exit 1
{{- else }}
              echo "upsertKineticaCrds.failOnError=false: continuing despite failures (sandbox tolerance)"
{{- end }}
            fi
            echo "Done: $REPLACED replaced, $SKIPPED skipped (not present), $FAILED failed"
      restartPolicy: OnFailure

{{- end }}
