{{- define "kinetica-operators.crds" }}

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
    # hook-succeeded is intentionally omitted so Helm doesn't delete the
    # Job on success — pod log stays around for inspection.
    # before-hook-creation cleans up the previous Job at the start of
    # the next deploy. ttlSecondsAfterFinished=1200 bounds retention.
    helm.sh/hook-delete-policy: before-hook-creation
    helm.sh/hook-weight: '-5'
spec:
  # 20-minute log-inspection window, then K8s TTL controller deletes the Job.
  ttlSecondsAfterFinished: 1200
  # backoffLimit: 0 — exactly one pod runs (no retries). Script always
  # exits 0 so the Job enters Complete state regardless of kubectl errors.
  backoffLimit: 0
  template:
    metadata:
      labels:
        app.kubernetes.io/name: kinetica-operators
        app.kubernetes.io/instance: '{{ .Release.Name }}'
    spec:
      serviceAccountName: kineticacluster-operator
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
            set +e
            REPLACED=""
            FAILED=""
            for F in /crds/db-crds/* /crds/wb-crds/*; do
              [ -f "$F" ] || continue
              CRD=$(grep -m1 '^  name:' "$F" | awk '{print $2}')
              [ -n "$CRD" ] || continue
              # Only attempt replace if the CRD already exists; first install
              # lets Helm create it.
              kubectl get crd "$CRD" >/dev/null 2>&1 || continue
              if ERR=$(kubectl replace -f "$F" 2>&1); then
                REPLACED="$REPLACED $CRD"
              else
                FAILED="$FAILED $CRD"
                printf 'FAILED %s: %s\n' "$CRD" "$(printf '%s' "$ERR" | head -1)"
              fi
            done
            if [ -n "$REPLACED" ]; then
              echo "Replaced CRDs:"
              for C in $REPLACED; do echo "  - $C"; done
            else
              echo "No CRDs required replacement."
            fi
            # Always exit 0 so the Job reaches Complete; ttlSecondsAfterFinished
            # bounds how long the pod log stays available for inspection.
            exit 0
      restartPolicy: Never

{{- end }}
