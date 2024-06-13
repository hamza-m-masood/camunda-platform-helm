{{/*
TODO: Remove the whole file just before 8.6 release.
NOTE: We need to load this file first thing before all other resources to support backward compatibility.

      Helm prioritizes files that are deeply nested in subdirectories when it's determining the render order.
      see the sort function in Helm:
      https://github.com/helm/helm/blob/d58d7b376265338e059ff11c71267b5a6cf504c3/pkg/engine/engine.go#L347-L356
      
      Because of this sort order, and that we have nested subcharts such that
      one of the rendered templates is:
      charts/keycloak/charts/postgresql/charts/common/templates/validations/_validations.tpl,
      we need this z_compatibility_helpers.tpl to be nested in at least 8 folders.

      In addition to the subdirectory ordering, Helm also orders the templates
      alphabetically descending within the same folder level, which is why it
      is named with a "z_" inside the zeebe directory. so Helm will process
      this file first, and all migration steps will be applied to all templates
      in the chart implicitly:
      https://github.com/helm/helm/blob/d58d7b376265338e059ff11c71267b5a6cf504c3/pkg/engine/engine.go#L362-L369
*/}}

{{/*
********************************************************************************
* Camunda 8.5 backward compatibility.

Overview:
    Backward compatibility with values syntax before Camunda Helm chart v10.0.0 (Camunda 8.5 cycle).

Approach:
    Using deep copy and deep merge functions to override new keys using the old key.
    https://helm.sh/docs/chart_template_guide/function_list/#mergeoverwrite-mustmergeoverwrite
********************************************************************************
*/}}

{{- define "identityKeycloakTheme" -}}
name: copy-camunda-theme
image: "{{ .Values.identityKeycloak.image.registry }}/{{ .Values.identityKeycloak.image.repository }}:{{ .Values.identityKeycloak.image.tag }}"
imagePullPolicy: "{{ .Values.identityKeycloak.image.pullPolicy }}"
command: ["sh", "-c", "cp -a /app/keycloak-theme/* /mnt"]
securityContext:
  privileged: {{ .Values.identityKeycloak.containerSecurityContext.privileged }}
  readOnlyRootFilesystem: {{ .Values.identityKeycloak.containerSecurityContext.readOnlyRootFilesystem }}
  allowPrivilegeEscalation: {{ .Values.identityKeycloak.containerSecurityContext.allowPrivilegeEscalation }}
  runAsNonRoot: {{ .Values.identityKeycloak.containerSecurityContext.runAsNonRoot }}
  {{- if ne .Values.identityKeycloak.global.compatibility.openshift.adaptSecurityContext "force" }}
  runAsUser: {{ .Values.identityKeycloak.containerSecurityContext.runAsUser }}
  {{- end }}
  capabilities: 
    drop: {{ .Values.identityKeycloak.containerSecurityContext.capabilities.drop }}
  seccompProfile:
    {{ toYaml .Values.identityKeycloak.containerSecurityContext.seccompProfile }}
volumeMounts:
- name: camunda-theme
  mountPath: /mnt
{{- end -}}

{{- $_ := set .Values.identityKeycloak "initContainers" (
    mustAppend .Values.identityKeycloak.initContainers (
        fromYaml (include "identityKeycloakTheme" .)
    )
) -}}
