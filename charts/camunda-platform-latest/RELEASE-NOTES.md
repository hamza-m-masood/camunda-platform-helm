The changelog is automatically generated using [git-chglog](https://github.com/git-chglog/git-chglog)
and it follows [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format.


<a name="camunda-platform-10.2.0"></a>
## [camunda-platform-10.2.0](https://github.com/camunda/camunda-platform-helm/releases/tag/camunda-platform-10.2.0) (2024-06-19)

### Ci

* automate release chores ([#2013](https://github.com/camunda/camunda-platform-helm/issues/2013))

### Feat

* add console auth vars ([#1782](https://github.com/camunda/camunda-platform-helm/issues/1782))

### Fix

* unauthenticated external elasticsearch no longer forces password… ([#1990](https://github.com/camunda/camunda-platform-helm/issues/1990))

### Release Info

Supported versions:

- Camunda applications: [8.5](https://github.com/camunda/camunda-platform/releases?q=tag%3A8.5&expanded=true)
- Helm values: [10.2.0](https://artifacthub.io/packages/helm/camunda/camunda-platform/10.2.0#parameters)
- Helm CLI: [3.15.1](https://github.com/helm/helm/releases/tag/v3.15.1)

Camunda images:

- docker.io/camunda/connectors-bundle:8.5.3
- docker.io/camunda/identity:8.5.2
- docker.io/camunda/identity:latest
- docker.io/camunda/operate:8.5.3
- docker.io/camunda/optimize:8.5.2
- docker.io/camunda/tasklist:8.5.2
- docker.io/camunda/zeebe:8.5.3
- registry.camunda.cloud/console/console-sm:8.5.52
- registry.camunda.cloud/web-modeler-ee/modeler-restapi:8.5.3
- registry.camunda.cloud/web-modeler-ee/modeler-webapp:8.5.3
- registry.camunda.cloud/web-modeler-ee/modeler-websockets:8.5.3

Non-Camunda images:

- docker.io/bitnami/elasticsearch:8.12.2
- docker.io/bitnami/keycloak:23.0.7
- docker.io/bitnami/os-shell:12-debian-12-r16
- docker.io/bitnami/postgresql:14.12.0
- docker.io/bitnami/postgresql:15.7.0

### Verification

To verify the integrity of the Helm chart using [Cosign](https://docs.sigstore.dev/signing/quickstart/):

```shell
cosign verify-blob camunda-platform-10.2.0.tgz \
  --bundle camunda-platform-10.2.0.cosign.bundle \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  --certificate-identity "https://github.com/camunda/camunda-platform-helm/.github/workflows/chart-release-chores.yml@refs/pull/2014/merge"
```
