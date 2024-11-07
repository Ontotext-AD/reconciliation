{{- define "ontotext-reconciliation.ingress.hostname" -}}
{{- if .Values.ingress.hosts -}}
{{- (first .Values.ingress.hosts).host -}}
{{- end -}}
{{- end -}}

{{- define "ontotext-reconciliation.ingress.protocol" -}}
{{- if .Values.ingress.tls -}}
{{- "https" -}}
{{- else -}}
{{- "http" -}}
{{- end -}}
{{- end -}}

{{- define "ontotext-reconciliation.ingress.url" -}}
{{- $protocol := include "ontotext-reconciliation.ingress.protocol" . -}}
{{- $host := include "ontotext-reconciliation.ingress.hostname" . -}}
{{- printf "%s://%s" $protocol $host -}}
{{- end -}}
