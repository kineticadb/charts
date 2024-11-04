{{- define "kinetica-operators.oscp-ingress-nginx-scc" }}

---
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    helm.sh/hook: pre-install
    helm.sh/hook-weight: "1"
    include.release.openshift.io/ibm-cloud-managed: "true"
    include.release.openshift.io/self-managed-high-availability: "true"
    include.release.openshift.io/single-node-developer: "true"
    release.openshift.io/create-only: "true"
  name: kinetica-ingress-nginx-scc
allowHostDirVolumePlugin: true
allowHostIPC: true
allowHostNetwork: true
allowHostPID: true
allowHostPorts: true
allowPrivilegeEscalation: true
allowPrivilegedContainer: true
allowedCapabilities:
- '*'
allowedUnsafeSysctls:
- '*'
defaultAddCapabilities: null
fsGroup:
  type: RunAsAny
groups:
- system:cluster-admins
- system:nodes
- system:masters
priority: null
readOnlyRootFilesystem: false
requiredDropCapabilities: null
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: RunAsAny
seccompProfiles:
- '*'
supplementalGroups:
  type: RunAsAny
users:
- system:serviceaccount:kinetica-system:ingress-nginx-admission
- system:serviceaccount:kinetica-system:ingress-nginx
- system:serviceaccount:kinetica-system:ingress-nginx-backend
volumes:
- '*'
{{- end }}
