{{- define "kinetica-operators.versions" }}
{{- $environmentVersions := ""}}
{{- if and (eq .Values.environment "onPrem") (eq .Values.provider "kind") }}
    {{- $strversions := (.Files.Get "files/versions.local.kind.yaml" )|fromYaml  }}   
    {{- $environmentVersions = $strversions| toYaml |b64enc}}
{{- end}}
{{- if $environmentVersions }}
environmentVersions: {{ $environmentVersions }}
{{- else}}
{{- end}}
{{- end }}