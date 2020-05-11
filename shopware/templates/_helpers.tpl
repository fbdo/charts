{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "shopware.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "shopware.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "shopware.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "shopware.labels" -}}
app.kubernetes.io/name: {{ include "shopware.name" . }}
helm.sh/chart: {{ include "shopware.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Labels to use on {deploy|sts}.spec.selector.matchLabels and svc.spec.selector
*/}}
{{- define "shopware.matchLabels" -}}
app.kubernetes.io/name: {{ include "shopware.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "mariadb.fullname" -}}
{{- printf "%s-%s" .Release.Name "mariadb" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "shopware.customHTAccessCM" -}}
{{- printf "%s" .Values.customHTAccessCM -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "shopware.imagePullSecrets" -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 does not support it, so we need to implement this if-else logic.
Also, we can not use a single if because lazy evaluation is not an option
*/}}
{{- if .Values.global }}
{{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- else if or .Values.image.pullSecrets .Values.metrics.image.pullSecrets }}
imagePullSecrets:
{{- range .Values.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- range .Values.metrics.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end -}}
{{- else if or .Values.image.pullSecrets .Values.metrics.image.pullSecrets }}
imagePullSecrets:
{{- range .Values.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- range .Values.metrics.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Return  the proper Storage Class
*/}}
{{- define "shopware.storageClass" -}}
{{/*
Helm 2.11 supports the assignment of a value to a variable defined in a different scope,
but Helm 2.9 and 2.10 does not support it, so we need to implement this if-else logic.
*/}}
{{- if .Values.global -}}
    {{- if .Values.global.storageClass -}}
        {{- if (eq "-" .Values.global.storageClass) -}}
            {{- printf "storageClassName: \"\"" -}}
        {{- else }}
            {{- printf "storageClassName: %s" .Values.global.storageClass -}}
        {{- end -}}
    {{- else -}}
        {{- if .Values.persistence.storageClass -}}
              {{- if (eq "-" .Values.persistence.storageClass) -}}
                  {{- printf "storageClassName: \"\"" -}}
              {{- else }}
                  {{- printf "storageClassName: %s" .Values.persistence.storageClass -}}
              {{- end -}}
        {{- end -}}
    {{- end -}}
{{- else -}}
    {{- if .Values.persistence.storageClass -}}
        {{- if (eq "-" .Values.persistence.storageClass) -}}
            {{- printf "storageClassName: \"\"" -}}
        {{- else }}
            {{- printf "storageClassName: %s" .Values.persistence.storageClass -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return  the proper Service Account Name
*/}}
{{- define "shopware.serviceAccountName" -}}
{{- if .Values.shopware.serviceAccountName -}}
{{- printf "%s" .Values.shopware.serviceAccountName -}}
{{- else -}}
{{- print "default" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "shopware.ingress.apiVersion" -}}
{{- if semverCompare "<1.14-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for deployment.
*/}}
{{- define "shopware.deployment.apiVersion" -}}
{{- if semverCompare "<1.14-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "apps/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Renders a value that contains template.
Usage:
{{ include "shopware.tplValue" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "shopware.tplValue" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Return the MariaDB Hostname
*/}}
{{- define "shopware.databaseHost" -}}
{{- if .Values.mariadb.enabled }}
    {{- printf "%s" (include "mariadb.fullname" .) -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.host -}}
{{- end -}}
{{- end -}}

{{/*
Return the MariaDB Port
*/}}
{{- define "shopware.databasePort" -}}
{{- if .Values.mariadb.enabled }}
    {{- printf "3306" -}}
{{- else -}}
    {{- printf "%d" (.Values.externalDatabase.port | int ) -}}
{{- end -}}
{{- end -}}

{{/*
Return the MariaDB Database Name
*/}}
{{- define "shopware.databaseName" -}}
{{- if .Values.mariadb.enabled }}
    {{- printf "%s" .Values.mariadb.db.name -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.database -}}
{{- end -}}
{{- end -}}

{{/*
Return the MariaDB User
*/}}
{{- define "shopware.databaseUser" -}}
{{- if .Values.mariadb.enabled }}
    {{- printf "%s" .Values.mariadb.db.user -}}
{{- else -}}
    {{- printf "%s" .Values.externalDatabase.user -}}
{{- end -}}
{{- end -}}

{{/*
Return the database secret name
*/}}
{{- define "shopware.databaseSecretName" -}}
{{- if .Values.mariadb.enabled }}
    {{- printf "%s" (include "mariadb.fullname" .) -}}
{{- else -}}
    {{- printf "%s-%s" .Release.Name "externaldb" -}}
{{- end -}}
{{- end -}}

{{/*
Return the shopware secret name
*/}}
{{- define "shopware.secretName" -}}
{{- printf "%s-%s" .Release.Name "shopware" -}}
{{- end -}}

{{/*
Return the Storefront URL
*/}}
{{- define "shopware.storefrontURL" -}}
{{- if .Values.shopware.storefrontURL }}
    {{- printf "%s" .Values.shopware.storefrontURL -}}
{{- else -}}
    {{- printf "%s" "http://shopware.local" -}}
{{- end -}}
{{- end -}}

{{/*
Return SW6 volume mounts
*/}}
{{- define "shopware.volumeMounts" -}}
- mountPath: "/sw6/config/jwt"
  name: shopware-data
  subPath: "config/jwt"
- mountPath: "/sw6/config/packages"
  name: shopware-data
  subPath: "config/packages"
- mountPath: "/sw6/config/secrets"
  name: shopware-data
  subPath: "config/secrets"
- mountPath: "/sw6/public/bundles"
  name: shopware-data
  subPath: "public/bundles"
- mountPath: "/sw6/public/css"
  name: shopware-data
  subPath: "public/css"
- mountPath: "/sw6/public/fonts"
  name: shopware-data
  subPath: "public/fonts"
- mountPath: "/sw6/public/js"
  name: shopware-data
  subPath: "public/js"
- mountPath: "/sw6/public/media"
  name: shopware-data
  subPath: "public/media"
- mountPath: "/sw6/public/sitemap"
  name: shopware-data
  subPath: "public/sitemap"
- mountPath: "/sw6/public/theme"
  name: shopware-data
  subPath: "public/theme"
- mountPath: "/sw6/public/thumbnail"
  name: shopware-data
  subPath: "public/thumbnail"
- mountPath: "/sw6/custom/plugins"
  name: shopware-data
  subPath: "custom/plugins"
- mountPath: "/sw6/custom/static-plugins"
  name: shopware-data
  subPath: "custom/static-plugins"
              
{{- end -}}

{{/*
Return SW6 environment variables
*/}}
{{- define "shopware.env" -}}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "shopware.databaseSecretName" . }}
      key: mariadb-password
- name: DATABASE_USERNAME
  value: {{ include "shopware.databaseUser" . | quote }}
- name: DATABASE_HOST
  value: {{ include "shopware.databaseHost" . | quote }}
- name: DATABASE_URL
  value: mysql://$(DATABASE_USERNAME):$(DATABASE_PASSWORD)@$(DATABASE_HOST):3306/shopware
- name: APP_URL
  value: {{ include "shopware.storefrontURL" . }}
- name: APP_SECRET
  value: "def0000086d2b7dff7427e926d7d7dfbc00d20744d04f6129148a8abbbe67c0d493062a9ad0cbd410536e2ee0339d7798dd2b8148f075ff63562abd74c5c5463cb43aafc"
- name: INSTANCE_ID
  value: "2376t27364726354uzwzrutwe238764273"
- name: APP_ENV
  value: {{ .Values.labels.env | quote }}
{{- end -}}

{{/*
Check if there are rolling tags in the images
*/}}
{{- define "shopware.checkRollingTags" -}}
{{- if and (contains "bitnami/" .Values.image.repository) (not (.Values.image.tag | toString | regexFind "-r\\d+$|sha256:")) }}
WARNING: Rolling tag detected ({{ .Values.image.repository }}:{{ .Values.image.tag }}), please note that it is strongly recommended to avoid using rolling tags in a production environment.
+info https://docs.bitnami.com/containers/how-to/understand-rolling-tags-containers/
{{- end }}
{{- end -}}