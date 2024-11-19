{{- define "elasticsearch.url" -}}
{{- printf "http://%s:%s" (include "elasticsearch.fullname" (index $.Subcharts.elasticsearch )) (.Values.elasticsearch.httpPort | toString ) }}
{{- end }}
