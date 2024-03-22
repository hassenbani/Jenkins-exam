{{/*
Generate a full name for the movie-service deployment.
*/}}
{{- define "movie-service.fullname" -}}
{{- printf "%s-%s" .Release.Name "movie-service" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

