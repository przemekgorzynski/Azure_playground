{{- /*
Return the name of the chart
*/ -}}
{{- define "myapp.name" -}}
logginapp
{{- end -}}

{{- /*
Return the full name of the release
*/ -}}
{{- define "myapp.fullname" -}}
{{ .Release.Name }}-{{ include "myapp.name" . }}
{{- end -}}
