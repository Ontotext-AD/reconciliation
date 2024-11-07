{{- if .Values.elasticsearch.enabled }}
{{- define "elasticsearch.url" -}}
{{- printf "http://%s:%s" (include "elasticsearch.fullname" (index $.Subcharts.elasticsearch )) (.Values.elasticsearch.service.ports.http | toString ) }}
{{- end }}
{{- end }}
