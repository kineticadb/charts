{{- define "kinetica-operators.db" }}
    {{- $dedicatedSaasEksAllowedRegions := list "aws_useast_1" "aws_useast_2" "aws_uswest_2" "aws_euwest_1"}}
    {{- $externalLoki := false }}
    {{- if (lookup "v1" "Service" "stats" "stats-loki") }}
      {{- $externalLoki = true }}
    {{- end }}
    {{- $payAsYouGo := .Values.db.payAsYouGo }}
    {{- if eq (typeOf .Values.db.payAsYouGo) "string" }}
      {{- $payAsYouGo = false }}
      {{- if eq .Values.db.payAsYouGo "true" }}
        {{- $payAsYouGo = true }}
      {{- end }}
    {{- end}}
   
    {{- if not $payAsYouGo }}
        {{- if or (not .Values.db.gpudbCluster.license) (eq .Values.db.gpudbCluster.license "payg") }}
            {{- fail "License Key is needed for BYOL, use --set db.gpudbCluster.license=your_license_key" }}
        {{- end }}
    {{- end }}
    
    {{- $gpuAcceleration := .Values.db.gpudbCluster.gpuAcceleration }}
    {{- if eq (typeOf .Values.db.gpudbCluster.gpuAcceleration) "string" }}
      {{- $gpuAcceleration = false }}
      {{- if eq .Values.db.gpudbCluster.gpuAcceleration "true" }}
        {{- $gpuAcceleration = true }}
      {{- end }}
    {{- end }}
    

apiVersion: app.kinetica.com/v1
kind: KineticaCluster
metadata:
  name: {{  .Values.db.name }}
  namespace: {{ default "gpudb" .Values.db.namespace }}
  labels:
    "app.kubernetes.io/name": "kinetica-operators"
    "app.kubernetes.io/managed-by": "Helm"
    "app.kubernetes.io/instance": "{{ .Release.Name }}"
    "helm.sh/chart": '{{ include "kinetica-operators.chart" . }}'
    
spec:
  {{- if eq (kindOf .Values.db.autoSuspend) "map" }}
  autoSuspend: 
    enabled: {{ .Values.db.autoSuspend.enabled }}
    inactivityDuration: {{ .Values.db.autoSuspend.inactivityDuration }}
  {{- end }}
  debug: {{ default false .Values.db.debug }}
  payAsYouGo: {{ $payAsYouGo }}
  {{- if and (eq .Values.environment "marketPlace") (eq .Values.provider "eks") }}
  awsConfig:
    clusterName: {{ required "Name of eks cluster is requried" .Values.db.awsConfig.clusterName }}
    marketplaceApp:
      productCode: {{ required "productCode is required" .Values.db.awsConfig.marketplaceApp.productCode }}
      publicKeyVersion: 1
  {{- else if and (eq .Values.environment "marketPlace") (eq .Values.provider "aks") }}
  azureConfig:
    managedApp:
      planId: {{ required "planId is required" .Values.db.azureConfig.managedApp.planId }}
      resourceUri: {{ required "resourceUri is required" .Values.db.azureConfig.managedApp.resourceUri }}
    appInsights:
      key: {{ required "appInsights key is required" .Values.db.azureConfig.appInsights.key }}
  {{- else if and (eq .Values.environment "saas") (eq .Values.provider "eks") }}
  deploymentType:
    type: dedicated_saas
    {{- if .Values.db.deploymentType.region }}
      {{- if has .Values.db.deploymentType.region $dedicatedSaasEksAllowedRegions }}
    region: {{ .Values.db.deploymentType.region }}
      {{- else }}
    {{- fail "Invalid region for dedicated_saas deployment type" }}
      {{- end }}
    {{- else }}
    {{- fail "Region is required for dedicated_saas deployment type" }}
    {{- end }}
  infra: "on-prem"
 
  {{- else }}
  deploymentType:
    type: on_prem
    region: on_prem_local
  infra: "on-prem"
  {{- end }}
  
  hostManagerMonitor:
    monitorRegistryRepositoryTag:
      {{- include "kinetica-operators.db.image" .Values.db.hostManagerMonitor.image | nindent 8 }}
    livenessProbe:
      failureThreshold: 30
  ingressController: {{ default "none" .Values.db.ingressController }}
  {{- if eq (kindOf .Values.db.ldap)  "map"}}
  ldap:
    baseDN: {{ default "dc=kinetica,dc=com" .Values.db.ldap.baseDN }}
    bindDN: {{ default "cn=admin,dc=kinetica,dc=com" .Values.db.ldap.bindDN }}
    host: {{ default "openldap" .Values.db.ldap.host }}
    isInLocalK8S: true
    isLDAPS: false
    namespace: gpudb
    port: {{ default 389 .Values.db.ldap.port }}
  {{- end }}
  supportingImages:
    busybox:
        {{- include "kinetica-operators.db.image" .Values.db.supportingImages.busybox.image | nindent 8 }}
    socat:
        {{- include "kinetica-operators.db.image" .Values.db.supportingImages.socat.image | nindent 8 }}
  stats:
    isEnabled: {{ .Values.db.stats.isEnabled }}
    alertManager:
      isEnabled: {{ .Values.db.alertManager.isEnabled }}
      {{- if eq (kindOf .Values.db.alertManager.image)  "map"}}
      image:
        {{- include "kinetica-operators.db.image" .Values.db.alertManager.image | nindent 8 }}
      {{- end }}
    grafana:
      isEnabled: {{ .Values.db.grafana.isEnabled }}
      {{- if eq (kindOf .Values.db.grafana.image)  "map"}}
      image:
        {{- include "kinetica-operators.db.image" .Values.db.grafana.image | nindent 8 }}
      {{- end }}
    loki:
      isEnabled: {{ .Values.db.loki.isEnabled }}
      {{- if eq (kindOf .Values.db.loki.image)  "map"}}
      image:
        {{- include "kinetica-operators.db.image" .Values.db.loki.image | nindent 8 }}
      {{- end }}
    prometheus:
      isEnabled: {{ .Values.db.prometheus.isEnabled }}
      {{- if eq (kindOf .Values.db.prometheus.image)  "map"}}
      image:
        {{- include "kinetica-operators.db.image" .Values.db.prometheus.image | nindent 8 }}
      {{- end }}
  gadmin:
    isEnabled: {{ .Values.db.gadmin.isEnabled }}
    containerPort:
      name: gadmin
      protocol: TCP
      containerPort: 8080
  reveal:
    isEnabled: {{ .Values.db.reveal.isEnabled }}
    containerPort:
      name: reveal
      protocol: TCP
      containerPort: 8088
  gpudbCluster:
    clusterSize:
      tshirtSize: {{ .Values.db.gpudbCluster.clusterSize.tshirtSize }}
      tshirtType: {{ .Values.db.gpudbCluster.clusterSize.tshirtType }}
    ranksPerNode: {{ .Values.db.gpudbCluster.ranksPerNode }}
    replicas: {{ .Values.db.gpudbCluster.replicas }}
    hasPools: {{ .Values.db.gpudbCluster.hasPools }}
    fqdn: {{ .Values.db.gpudbCluster.fqdn }}
    letsEncrypt: 
      enabled: {{ .Values.db.gpudbCluster.letsEncrypt.enabled }}
      environment: {{ .Values.db.gpudbCluster.letsEncrypt.environment | default "staging" }}
    podManagementPolicy: Parallel
    license: {{ .Values.db.gpudbCluster.license | default "payg" }}
    {{- if $gpuAcceleration  }}
    image: "{{ .Values.db.gpudbCluster.image.cuda.image.repository }}:{{ .Values.db.gpudbCluster.image.cuda.image.tag}}"
    {{- else }}
    image: "{{ .Values.db.gpudbCluster.image.standard.image.repository }}:{{ .Values.db.gpudbCluster.image.standard.image.tag}}"
    {{- end}}
    clusterName: {{  .Values.db.name }}
    {{- if eq (kindOf .Values.db.gpudbCluster.resources) "map" }} 
    resources:
      {{- if eq (kindOf .Values.db.gpudbCluster.resources.limits) "map" }}
      limits: 
        {{- if eq (kindOf .Values.db.gpudbCluster.resources.limits.cpu) "string" }}
        cpu: {{ .Values.db.gpudbCluster.resources.limits.cpu }}
        {{- end }}
        {{- if hasKey .Values.db.gpudbCluster.resources.limits "ephemeral-storage" }}
        ephemeral-storage: {{ get .Values.db.gpudbCluster.resources.limits "ephemeral-storage" }}
        {{- end }}
        {{- if eq (kindOf .Values.db.gpudbCluster.resources.limits.memory) "string" }}
        memory: {{ .Values.db.gpudbCluster.resources.limits.memory }}
        {{- end }}
      {{- end }}
      {{- if eq (kindOf .Values.db.gpudbCluster.resources.requests) "map" }}
      requests:
        {{- if eq (kindOf .Values.db.gpudbCluster.resources.requests.cpu) "string" }}
        cpu: {{ .Values.db.gpudbCluster.resources.requests.cpu }}
        {{- end }}
        {{- if hasKey .Values.db.gpudbCluster.resources.requests "ephemeral-storage" }}
        ephemeral-storage: {{ get .Values.db.gpudbCluster.resources.requests "ephemeral-storage" }}
        {{- end }}
        {{- if eq (kindOf .Values.db.gpudbCluster.resources.requests.memory) "string" }}
        memory: {{ .Values.db.gpudbCluster.resources.requests.memory }}
        {{- end }}
      {{- end }}
    {{- end }}  
    metricsRegistryRepositoryTag:
        {{- include "kinetica-operators.db.image" .Values.db.gpudbCluster.metricsRegistryRepositoryTag.image | nindent 8 }}
    config:
      {{- if and (eq (kindOf .Values.db.gpudbCluster.config.postgresProxy) "map") .Values.db.gpudbCluster.config.postgresProxy.enablePostgresProxy }}
      postgresProxy:
         enablePostgresProxy: true
      {{- end }}
      {{- if and (eq (kindOf .Values.db.gpudbCluster.config.kifs) "map") .Values.db.gpudbCluster.config.kifs.enable }}
      kifs:
        enable: true
        mountPoint: {{ default "/gpudb/kifs" .Values.db.gpudbCluster.config.kifs.mountPoint }}
      {{- end }}
      {{- if and (eq (kindOf .Values.db.gpudbCluster.config.procs) "map") .Values.db.gpudbCluster.config.procs.enable }}
      procs:
        enable: true
      {{- end }}
      {{- if and (eq (kindOf .Values.db.gpudbCluster.config.textSearch) "map") .Values.db.gpudbCluster.config.textSearch.enableTextSearch }}
      textSearch:
        enableTextSearch: true
      {{- end }}
      {{- if $externalLoki }}
      events:
        internal: false
        port: 9080
        ipAddress: "http://stats-loki.stats"
        statsServerNamespace: "stats"
      {{- end }}

      {{- if eq (kindOf .Values.db.gpudbCluster.config.tieredStorage) "map" }}
      tieredStorage:
        globalTier:
          colocateDisks: {{ .Values.db.gpudbCluster.config.tieredStorage.globalTier.colocateDisks }}
          
        {{- if eq (kindOf .Values.db.gpudbCluster.config.tieredStorage.ramTier) "map" }}
        ramTier:
          default:
            limit: {{ .Values.db.gpudbCluster.config.tieredStorage.ramTier.default.limit }}
        {{- end }}
        {{- if eq (kindOf .Values.db.gpudbCluster.config.tieredStorage.persistTier) "map" }}
        persistTier:
          default:
            provisioner: {{ default .Values.storageProvisioner .Values.db.gpudbCluster.config.tieredStorage.persistTier.default.provisioner }}
            limit: {{ .Values.db.gpudbCluster.config.tieredStorage.persistTier.default.limit }}
            volumeClaim:
              spec:
                storageClassName: {{ default .Values.global.defaultStorageClass .Values.db.gpudbCluster.config.tieredStorage.persistTier.default.volumeClaim.spec.storageClassName }}
        {{- end }}
        {{- if eq (kindOf .Values.db.gpudbCluster.config.tieredStorage.diskCacheTier) "map" }}
        diskCacheTier:
          default:
            provisioner: {{ default .Values.storageProvisioner .Values.db.gpudbCluster.config.tieredStorage.diskCacheTier.default.provisioner }}
            limit: {{ .Values.db.gpudbCluster.config.tieredStorage.diskCacheTier.default.limit }}
            volumeClaim:
              spec:
                storageClassName: {{ default .Values.global.defaultStorageClass .Values.db.gpudbCluster.config.tieredStorage.diskCacheTier.default.volumeClaim.spec.storageClassName }}
        {{- end }}
        {{- if eq (kindOf .Values.db.gpudbCluster.config.tieredStorage.coldStorageTier) "map" }}
        coldStorageTier:
          coldStorageType: {{ .Values.db.gpudbCluster.config.tieredStorage.coldStorageTier.coldStorageType }}
          {{- if eq .Values.db.gpudbCluster.config.tieredStorage.coldStorageTier.coldStorageType "s3" }}
          coldStorageS3:
            region: "{{ .Values.clusterRegion }}"
            endpoint: "s3.{{ .Values.clusterRegion }}.amazonaws.com"
            basePath: "gpudb/cold-storage/"
            bucketName: {{ .Values.db.gpudbCluster.config.tieredStorage.coldStorageTier.coldStorageS3.bucketName }}
          {{- end }}
          {{- if eq .Values.db.gpudbCluster.config.tieredStorage.coldStorageTier.coldStorageType "azure_blob" }}
          coldStorageAzure:
            basePath: "gpudb/cold_storage/"
            containerName: {{ .Values.db.gpudbCluster.config.tieredStorage.coldStorageTier.coldStorageAzure.containerName }}
            sasToken: {{ .Values.db.gpudbCluster.config.tieredStorage.coldStorageTier.coldStorageAzure.sasToken }}
            storageAccountKey: {{ .Values.db.gpudbCluster.config.tieredStorage.coldStorageTier.coldStorageAzure.storageAccountKey }}
            storageAccountName: {{ .Values.db.gpudbCluster.config.tieredStorage.coldStorageTier.coldStorageAzure.storageAccountName }}
          {{- end }}
          {{- if eq .Values.db.gpudbCluster.config.tieredStorage.coldStorageTier.coldStorageType "disk" }}
          coldStorageDisk:
            basePath: "/opt/gpudb/cold"
            provisioner: {{ default .Values.storageProvisioner .Values.db.gpudbCluster.config.tieredStorage.coldStorageTier.coldStorageDisk.provisioner }}
            volumeClaim:
              spec:
                storageClassName: {{ default .Values.global.defaultStorageClass .Values.db.gpudbCluster.config.tieredStorage.coldStorageTier.coldStorageDisk.volumeClaim.spec.storageClassName }}
          {{- end }}
        {{- end }}
      {{- end }}
---
{{ end -}}
