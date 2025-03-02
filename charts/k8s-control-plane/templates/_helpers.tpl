{{- define "k8s-control-plane.kubectl-image" -}}
{{- $version := semver $.Values.version -}}
bitnami/kubectl:{{ $version.Major }}.{{ $version.Minor }}
{{- end }}
