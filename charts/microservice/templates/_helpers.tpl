{{/*
Expand the name of the chart.
*/}}
{{- define "microservice.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "microservice.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "microservice.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "microservice.labels" -}}
helm.sh/chart: {{ include "microservice.chart" . }}
{{ include "microservice.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "microservice.selectorLabels" -}}
app.kubernetes.io/name: {{ include "microservice.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "microservice.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "microservice.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
This function checks if at least one of the conditions is true:
1. The list Values.secrets.objects is not empty.
2. The boolean field Values.persistence.mongo.enabled is true.
3. The boolean field Values.persistence.rds.enabled is true.
4. The boolean field Values.kafka.enabled is true
*/}}
{{- define "secrets.enabled" -}}
{{- $result := "no" -}}
{{- if or (ne (len .Values.secrets.keys) 0) -}}
{{- $result = "yes" -}}
{{- end -}}
{{- $result -}}
{{- end -}}


{{/*
This function checks if at least one infrastructure component should be enabled.
The conditions are:
1. is secrets.enabled
*/}}
{{- define "infrastructure.enabled" -}}
{{- $result := "no" -}}
{{ if eq (include "secrets.enabled" .) "yes" -}}
{{- $result = "yes" -}}
{{- end -}}
{{- $result -}}
{{- end -}}




{{- define "kafkaTopicsToString" -}}
{{- $partitions := .Values.kafka.partitions -}}
{{- $parsedJson := .Values.kafka.topics -}}
{{- $result := list -}}
{{- range $index, $item := $parsedJson -}}
  {{- if not $item.partitions -}}
    {{- $item = merge $item (dict "partitions" $partitions) -}}
  {{- end -}}
  {{- $result = append $result $item -}}
{{- end -}}
{{- $result | toJson -}}
{{- end }}

{{- define "concatenateConnectionOptions" -}}
{{- $result := "&" -}}
{{- range $key, $value := . -}}
  {{- $result = printf "%s%s=%s&" $result $key $value -}}
{{- end -}}
{{- $result | trimSuffix "&" -}}
{{- end -}}

{*JVM customisation*}
{{- define "javaToolOptions" -}}
-Xms{{.Values.jvm.memory.heap}}m -Xmx{{.Values.jvm.memory.heap}}m -XX:MetaspaceSize={{.Values.jvm.memory.metaspace}}m -XX:MaxMetaspaceSize={{.Values.jvm.memory.metaspace}}m -XX:CompressedClassSpaceSize={{.Values.jvm.memory.compressedClassSpaceSize}}m -XX:+TieredCompilation -XX:+SegmentedCodeCache -XX:NonNMethodCodeHeapSize={{.Values.jvm.memory.nonMethodCodeHeapSize}}m -XX:ProfiledCodeHeapSize={{.Values.jvm.memory.profiledCodeHeapSize}}m -XX:NonProfiledCodeHeapSize={{.Values.jvm.memory.nonProfiledCodeHeapSize}}m -XX:ReservedCodeCacheSize={{ add .Values.jvm.memory.nonMethodCodeHeapSize .Values.jvm.memory.profiledCodeHeapSize .Values.jvm.memory.nonProfiledCodeHeapSize}}m
{{- end -}}

{*Datadog agent options*}
{{- define "ddAgentJavaOptions" -}}
-Ddatadog.slf4j.simpleLogger.dateTimeFormat="yyyy-MM-dd HH:mm:ss.SSS" -Ddatadog.slf4j.simpleLogger.logFile=System.out
{{- end -}}

{{- define "pluginNames" -}}
{{- $fullname := .fullname }}
{{- $plugins := .plugins -}}
{{- $pluginNames := list -}}
{{- range $plugin := $plugins -}}
{{- $pluginNames = append $pluginNames (printf "%s-%s" $fullname $plugin.name) -}}
{{- end -}}
{{- join ", " $pluginNames -}}
{{- end -}}

{{- define "generateTerraformSource" -}}
{{- printf "%s?ref=%s" .Values.terraform.source.address .Values.terraform.source.ref -}}
{{- end }}