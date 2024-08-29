{{- if .Values.graphdb.enabled }}

{{- define "graphdb.url" -}}
{{- if and (gt (int64 .Values.graphdb.replicas) 1) }}
{{- printf "http://%s:%s"  (include "graphdb-proxy.fullname" (index $.Subcharts.graphdb )) (.Values.graphdb.proxy.service.ports.http | toString ) }}
{{- else }}
{{- printf "http://%s:%s" (include "graphdb.fullname" (index $.Subcharts.graphdb )) (.Values.graphdb.service.ports.http | toString ) }}
{{- end }}
{{- end }}


{{- define "graphdb.context-path" -}}
{{- $gdb_url := urlParse .Values.graphdb.configuration.externalUrl -}}
{{- printf "%s" ($gdb_url.path | toString) -}}
{{- end }}

{{- define "graphdb.repo" -}}
{{- printf "example" -}}
{{- end }}

{{- define "graphdb.example.repo.sparql" -}}
{{- printf "%s/repositories/%s" (include "graphdb.url" .) (include "graphdb.repo" .) -}}
{{- end }}

{{- end }}