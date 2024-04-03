

{{- define "operate.spec.template.spec.containers" }}
        - name: operate
          image: {{ include "camundaPlatform.imageByParams" (dict "base" .Values.global "overlay" .Values.operate) }}
          imagePullPolicy: {{ .Values.global.image.pullPolicy }}
          {{- if .Values.operate.containerSecurityContext }}
          securityContext: {{- toYaml .Values.operate.containerSecurityContext | nindent 12 }}
          {{- end }}
          env:
            {{- if .Values.global.elasticsearch.external }}
            - name: CAMUNDA_OPERATE_ELASTICSEARCH_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ include "elasticsearch.authExistingSecret" . | quote }}
                  key: {{ include "elasticsearch.authExistingSecretKey" . | quote }}
            - name: CAMUNDA_OPERATE_ZEEBE_ELASTICSEARCH_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ include "elasticsearch.authExistingSecret" . | quote }}
                  key: {{ include "elasticsearch.authExistingSecretKey" . | quote }}
            {{- end }}
            {{- if .Values.global.opensearch.enabled }}
            - name: CAMUNDA_OPERATE_ZEEBE_OPENSEARCH_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ include "opensearch.authExistingSecret" . | quote }}
                  key: {{ include "opensearch.authExistingSecretKey" . | quote }}
            - name: CAMUNDA_OPERATE_OPENSEARCH_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ include "opensearch.authExistingSecret" . | quote }}
                  key: {{ include "opensearch.authExistingSecretKey" . | quote }}
            {{- end }}
            {{- if or .Values.global.elasticsearch.tls.existingSecret .Values.global.opensearch.tls.existingSecret }}
            - name: JAVA_TOOL_OPTIONS
              value: -Djavax.net.ssl.trustStore=/usr/local/operate/certificates/externaldb.jks
            {{- end }}
            {{- if .Values.global.identity.auth.enabled }}
            - name: CAMUNDA_IDENTITY_CLIENT_SECRET
              {{- if and .Values.global.identity.auth.operate.existingSecret (not (typeIs "string" .Values.global.identity.auth.operate.existingSecret)) }}
              valueFrom:
                secretKeyRef:
                  {{- /*
                      Helper: https://github.com/bitnami/charts/blob/master/bitnami/common/templates/_secrets.tpl
                      Usage in keycloak secrets https://github.com/bitnami/charts/blob/master/bitnami/keycloak/templates/secrets.yaml
                      and in statefulset https://github.com/bitnami/charts/blob/master/bitnami/keycloak/templates/statefulset.yaml
                  */}}
                  name: {{ include "common.secrets.name" (dict "existingSecret" .Values.global.identity.auth.operate.existingSecret "context" $) }}
                  key: operate-secret
              {{- else }}
              valueFrom:
                secretKeyRef:
                  {{- /*
                      Helper: https://github.com/bitnami/charts/blob/master/bitnami/common/templates/_secrets.tpl
                      Usage in keycloak secrets https://github.com/bitnami/charts/blob/master/bitnami/keycloak/templates/secrets.yaml
                      and in statefulset https://github.com/bitnami/charts/blob/master/bitnami/keycloak/templates/statefulset.yaml
                  */}}
                  name: {{ include "camundaPlatform.identitySecretName" (dict "context" . "component" "operate") }}
                  key: operate-secret
              {{- end }}
            - name: ZEEBE_CLIENT_ID
              value: {{ tpl .Values.global.identity.auth.zeebe.clientId $ | quote }}
            - name: ZEEBE_CLIENT_SECRET
              {{- if and .Values.global.identity.auth.zeebe.existingSecret (not (typeIs "string" .Values.global.identity.auth.zeebe.existingSecret)) }}
              valueFrom:
                secretKeyRef:
                  name: {{ include "common.secrets.name" (dict "existingSecret" .Values.global.identity.auth.zeebe.existingSecret "context" $) }}
                  key: zeebe-secret
              {{- else }}
              valueFrom:
                secretKeyRef:
                  name: {{ include "camundaPlatform.identitySecretName" (dict "context" . "component" "zeebe") }}
                  key: zeebe-secret
              {{- end }}
            - name: ZEEBE_AUTHORIZATION_SERVER_URL
              value: {{ include "camundaPlatform.authIssuerBackendUrlTokenEndpoint" . | quote }}
            - name: ZEEBE_TOKEN_AUDIENCE
              value: {{ include "zeebe.audience" . | quote }}
            {{- if .Values.global.identity.auth.zeebe.tokenScope }}
            - name: ZEEBE_TOKEN_SCOPE
              value: {{ include "zeebe.tokenScope" . | quote }}
            {{- end }}
            {{- end }}
            - name: ZEEBE_CLIENT_CONFIG_PATH
              value: /tmp/zeebe_auth_cache
          {{- with .Values.operate.env }}
            {{- tpl (toYaml .) $ | nindent 12 }}
          {{- end }}
          {{- if .Values.global.identity.auth.enabled }}
          envFrom:
            - configMapRef:
                name: {{ include "camundaPlatform.fullname" . }}-identity-env-vars
          {{- end }}
          {{- if .Values.operate.command }}
          command: {{ toYaml .Values.operate.command | nindent 10 }}
          {{- end }}
          resources:
            {{- toYaml .Values.operate.resources | nindent 12 }}
          ports:
            - containerPort: 8080
              name: http
              protocol: TCP
          {{- if .Values.operate.startupProbe.enabled }}
          startupProbe:
            httpGet:
              path: {{ .Values.operate.contextPath }}{{ .Values.operate.startupProbe.probePath }}
              scheme: {{ .Values.operate.startupProbe.scheme }}
              port: http
            initialDelaySeconds: {{ .Values.operate.startupProbe.initialDelaySeconds }}
            periodSeconds: {{ .Values.operate.startupProbe.periodSeconds }}
            successThreshold: {{ .Values.operate.startupProbe.successThreshold }}
            failureThreshold: {{ .Values.operate.startupProbe.failureThreshold }}
            timeoutSeconds: {{ .Values.operate.startupProbe.timeoutSeconds }}
          {{- end }}
          {{- if .Values.operate.readinessProbe.enabled }}
          readinessProbe:
            httpGet:
              path: {{ .Values.operate.contextPath }}{{ .Values.operate.readinessProbe.probePath }}
              scheme: {{ .Values.operate.readinessProbe.scheme }}
              port: http
            initialDelaySeconds: {{ .Values.operate.readinessProbe.initialDelaySeconds }}
            periodSeconds: {{ .Values.operate.readinessProbe.periodSeconds }}
            successThreshold: {{ .Values.operate.readinessProbe.successThreshold }}
            failureThreshold: {{ .Values.operate.readinessProbe.failureThreshold }}
            timeoutSeconds: {{ .Values.operate.readinessProbe.timeoutSeconds }}
          {{- end }}
          {{- if .Values.operate.livenessProbe.enabled }}
          livenessProbe:
            httpGet:
              path: {{ .Values.operate.contextPath }}{{ .Values.operate.livenessProbe.probePath }}
              scheme: {{ .Values.operate.livenessProbe.scheme }}
              port: http
            initialDelaySeconds: {{ .Values.operate.livenessProbe.initialDelaySeconds }}
            periodSeconds: {{ .Values.operate.livenessProbe.periodSeconds }}
            successThreshold: {{ .Values.operate.livenessProbe.successThreshold }}
            failureThreshold: {{ .Values.operate.livenessProbe.failureThreshold }}
            timeoutSeconds: {{ .Values.operate.livenessProbe.timeoutSeconds }}
          {{- end }}
          volumeMounts:
            - name: config
              mountPath: /usr/local/operate/config/application.yml
              subPath: application.yml
            - name: tmp
              mountPath: /tmp
            - name: camunda
              mountPath: /camunda
            {{- range $key, $val := .Values.operate.extraConfiguration }}
            - name: config
              mountPath: /usr/local/operate/config/{{ $key }}
              subPath: {{ $key }}
            {{- end }}
            {{- if or .Values.global.elasticsearch.tls.existingSecret .Values.global.opensearch.tls.existingSecret }}
            - name: keystore
              mountPath: /usr/local/operate/certificates/externaldb.jks
              subPath: externaldb.jks
            {{- end }}
            {{- if .Values.operate.extraVolumeMounts }}
            {{- .Values.operate.extraVolumeMounts | toYaml | nindent 12 }}
            {{- end }}
        {{- if .Values.operate.sidecars }}
        {{- .Values.operate.sidecars | toYaml | nindent 8 }}
        {{- end }}
{{- end }}


{{- define "operate.spec.template.spec.volumes" }}
        - name: tmp
          emptyDir: {}
        - name: camunda
          emptyDir: {}
        {{- if .Values.global.elasticsearch.tls.existingSecret }}
        - name: keystore
          secret:
            secretName: {{ .Values.global.elasticsearch.tls.existingSecret }}
            optional: false
        {{- end }}
        {{- if .Values.global.opensearch.tls.existingSecret }}
        - name: keystore
          secret:
            secretName: {{ .Values.global.opensearch.tls.existingSecret }}
            optional: false
        {{- end }}
        {{- if .Values.operate.extraVolumes }}
        {{- .Values.operate.extraVolumes | toYaml | nindent 8 }}
        {{- end }}
{{- end }}
