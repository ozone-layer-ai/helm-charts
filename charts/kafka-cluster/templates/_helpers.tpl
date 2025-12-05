{{- define "kafka.fullname" -}}
{{ include "kafka.name" . }}
{{- end }}

{{- define "kafka.name" -}}
{{ .Values.kafka.name }}
{{- end }}
