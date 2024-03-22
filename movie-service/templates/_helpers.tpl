{{/* Helper function to get the full name of the chart */}}
{{- define "movie-service.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name -}}
{{- end }}

{{/* Helper function to get the name of the chart */}}
{{- define "movie-service.name" -}}
{{- .Chart.Name -}}
{{- end }}

