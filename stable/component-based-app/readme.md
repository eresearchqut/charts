# component-based-app

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Generic library chart for a research application deployment.

## Prerequisites

When using the database, the following prerequisites are required.

1. The namespace must have the label `app/managed-by: cnpg-operator` for CNPG
   to discover and manage the database cluster.
2. A database credential secret containing a `username` and `password` key provided to `database.secretName`

## Installing the Chart

To install this chart with the release name `component-based-app`:

```console
$ helm repo add eresearchqut https://eresearchqut.github.io/charts/
$ helm install component-based-app eresearchqut/component-based-app
```

## Configuration
### Helm Metadata

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| appVersion | string | `""` | Application version. Set this to tag Deployments with a meaningful version string. |
| fullnameOverride | string | `""` | Helm release full name override. |
| global | object | `{}` | Global values for subchart inheritance. Reserved for values shared across subcharts via Helm's global convention. |
| nameOverride | string | `""` | Helm release name override. |
### Components

Used to create deployment-service-ingress-netpol. Designed to encapsulate a
"component" of the application, for example the "backend" or "frontend" or even a "worker"

Component keys must be valid Kubernetes DNS label names (lowercase alphanumeric + hyphens).

Every component requires at minimum `image.repository`, `image.tag`, `port`, and
`command`.

Adding extras such as liveness/readiness probes is recommended.

#### Application Secrets

Each component can reference secrets via `appSecretKeys`. The values are from the secret in `components.*.secretName`. Each `appSecretKeys` entry maps a secret key to an environment variable:

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| components.* | object | `{}` | Application component, key must be a valid kubernetes dns label |
| components.*.affinity | [core/v1.Affinity](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.core/v1.Affinity) | `nil` | Affinity and anti-affinity rules for pod scheduling. |
| components.*.allowedHostsEnvName | string | `nil` | Environment variable set to `<service-name>,$(POD_IP)`. Requires `podIPEnvName`. |
| components.*.appSecretKeys | list | `nil` | Environment variables sourced from a Kubernetes Secret. |
| components.*.appSecretKeys[0].envName | string | `nil` | Name of the environment variable exposed to the container. |
| components.*.appSecretKeys[0].secretKey | string | `nil` | Key within the referenced Kubernetes Secret. |
| components.*.command | list | `[]` | Command and arguments passed to the container (overrides image ENTRYPOINT). |
| components.*.containerSecurityContext | [core/v1.SecurityContext](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.core/v1.SecurityContext) | `nil` | Per-component container security context. Overrides the global `containerSecurityContext`. Set to `{}` to opt out. |
| components.*.env | list of [core/v1.EnvVar](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.core/v1.EnvVar) | `[]` | Additional environment variables in Kubernetes EnvVar format. |
| components.*.extraEgress | list of [networking/v1.NetworkPolicyEgressRule](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.networking/v1.NetworkPolicyEgressRule) | `[]` | Additional NetworkPolicy egress rules. Only meaningful when `networkPolicy` is configured. |
| components.*.extraIngress | list of [networking/v1.NetworkPolicyIngressRule](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.networking/v1.NetworkPolicyIngressRule) | `[]` | Additional NetworkPolicy ingress rules. Only meaningful when `networkPolicy` is configured. |
| components.*.image | object | `nil` | Container image reference. |
| components.*.image.repository | string | `nil` | Container image repository (e.g., registry.example.com/myapp). |
| components.*.image.tag | string | `nil` | Container image tag. Required — no default is applied. |
| components.*.initContainer | object | `nil` | Init container that runs before the main container. Uses the same image as the component. |
| components.*.initContainer.command | list | `nil` | Init container command and arguments. |
| components.*.injectDatabase | bool | `nil` | When true, injects `DB_USERNAME`, `DB_PASSWORD`, `DB_HOST`, and `DB_PORT` from the database secret. |
| components.*.livenessProbe | object | `nil` | Container liveness probe. Omit the block to disable. |
| components.*.livenessProbe.failureThreshold | int | `nil` | Consecutive failures before restart. |
| components.*.livenessProbe.initialDelaySeconds | int | `nil` | Delay before first probe. |
| components.*.livenessProbe.path | string | `nil` | HTTP path for the liveness probe (e.g., /healthz). |
| components.*.livenessProbe.periodSeconds | int | `nil` | Interval between probes. |
| components.*.livenessProbe.successThreshold | int | `nil` | Consecutive successes to mark ready. |
| components.*.livenessProbe.timeoutSeconds | int | `nil` | Probe timeout. |
| components.*.monitoring | object | `nil` | Prometheus ServiceMonitor configuration. Requires prometheus-operator. Omit to disable. |
| components.*.monitoring.interval | string | `nil` | Prometheus scrape interval. |
| components.*.monitoring.path | string | `nil` | HTTP path for the metrics endpoint. |
| components.*.monitoring.port | string | `nil` | Name of the port exposing metrics on the Service. |
| components.*.monitoring.scrapeTimeout | string | `nil` | Prometheus scrape timeout. |
| components.*.nodeSelector | object | `nil` | Node labels for pod assignment. |
| components.*.podAnnotations | object | `nil` | Annotations added to the component's Pod. |
| components.*.podDisruptionBudget | object | `nil` | PodDisruptionBudget configuration. Auto-created for components with replicas > 1 or autoscaling. Set explicitly to override. |
| components.*.podDisruptionBudget.maxUnavailable | int | `nil` | Maximum number of unavailable pods during voluntary disruptions. Can be int or percentage string. |
| components.*.podDisruptionBudget.minAvailable | int | `nil` | Minimum number of available pods during voluntary disruptions. Can be int or percentage string (e.g., "50%"). |
| components.*.podIPEnvName | string | `nil` | Name of the environment variable that receives the pod's IP via the Downward API. |
| components.*.podLabels | object | `nil` | Labels added to the component's Pod. |
| components.*.podSecurityContext | [core/v1.PodSecurityContext](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.core/v1.PodSecurityContext) | `nil` | Per-component pod security context. Overrides the global `podSecurityContext`. Set to `{}` to opt out. |
| components.*.port | int | `nil` | Port the container listens on. Exposed as the Service port and injected as `PORT`. |
| components.*.readinessProbe | object | `nil` | Container readiness probe. Omit the block to disable. |
| components.*.readinessProbe.failureThreshold | int | `nil` | Consecutive failures before marking unready. |
| components.*.readinessProbe.initialDelaySeconds | int | `nil` | Delay before first probe. |
| components.*.readinessProbe.path | string | `nil` | HTTP path for the readiness probe. |
| components.*.readinessProbe.periodSeconds | int | `nil` | Interval between probes. |
| components.*.readinessProbe.successThreshold | int | `nil` | Consecutive successes to mark ready. |
| components.*.readinessProbe.timeoutSeconds | int | `nil` | Probe timeout. |
| components.*.replicas | int | `nil` | Number of replicas. |
| components.*.resources | [core/v1.ResourceRequirements](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.core/v1.ResourceRequirements) | `nil` | Per-component resource requests and limits. Falls back to top-level `resources` when not set. |
| components.*.secretName | string | `nil` | Name of the Kubernetes Secret that backs `appSecretKeys` entries. Defaults to `<fullname>-secrets` when empty. |
| components.*.serviceLinks | list | `nil` | Injects HTTP URLs pointing to sibling component Services as environment variables. |
| components.*.serviceLinks[0].envName | string | `nil` | Name of the environment variable that receives the URL. |
| components.*.serviceLinks[0].path | string | `nil` | URL path appended to the service URL. |
| components.*.serviceLinks[0].targetName | string | `nil` | Key of the target component in this chart. |
| components.*.startupProbe | object | `nil` | Startup probe for slow-starting applications. Set `path` to enable; omit to disable. |
| components.*.startupProbe.failureThreshold | int | `nil` | Consecutive failures before the container is killed. Defaults higher (30) for slow starts. |
| components.*.startupProbe.initialDelaySeconds | int | `nil` | Delay before first probe. |
| components.*.startupProbe.path | string | `nil` | HTTP path for the startup probe. Empty string disables it. |
| components.*.startupProbe.periodSeconds | int | `nil` | Interval between probes. |
| components.*.startupProbe.timeoutSeconds | int | `nil` | Probe timeout. |
| components.*.tolerations | list of [core/v1.Toleration](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.core/v1.Toleration) | `[]` | Tolerations for pod scheduling onto tainted nodes. |
| components.*.volumeMounts | list of [core/v1.VolumeMount](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.core/v1.VolumeMount) | `[]` | Additional volume mounts into the component's main container. |
| components.*.volumes | list of [core/v1.Volume](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.core/v1.Volume) | `[]` | Additional volumes attached to the component's Pod. |

### Database

CloudNativePG PostgreSQL cluster. When set, creates a `Cluster` resource with
configurable instances, storage, and resource limits.

- Remember to set the namespace label and secrets.
- `database.image.tag` is **required** — no default version is applied.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| database.extraEgress | list of [networking/v1.NetworkPolicyEgressRule](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.networking/v1.NetworkPolicyEgressRule) | `[]` | Additional NetworkPolicy egress rules appended to the database NetworkPolicy. Only meaningful when networkPolicy is set. Standard Kubernetes NetworkPolicyEgressRule format (e.g., S3 for WAL archiving). |
| database.image.repository | string | `"registry.eres.qut.edu.au/ghcr/cloudnative-pg/postgresql"` | CloudNativePG PostgreSQL image repository. |
| database.image.tag | Required | `"17"` | CloudNativePG PostgreSQL image tag (version). Must be set explicitly. |
| database.instances | int | `1` | Number of CNPG cluster instances. Set > 1 for high availability. |
| database.resources.limits.cpu | string | `"1"` | CPU limit for the database instance. |
| database.resources.limits.memory | string | `"1Gi"` | Memory limit for the database instance. |
| database.resources.requests.cpu | string | `"0.5"` | CPU request for the database instance. |
| database.resources.requests.memory | string | `"256Mi"` | Memory request for the database instance. |
| database.secretName | string | `""` | Name of the secret containing database credentials. |
| database.storageClass | string | `""` | PVC storage class for the database. Defaults to cluster default when empty. |
| database.storageSize | string | `"8Gi"` | PVC storage size for the database (Kubernetes quantity). |
| database.walStorageClass | string | `""` | PVC storage class for WAL. Defaults to cluster default when empty. |
| database.walStorageSize | string | `"2Gi"` | PVC storage size for WAL (Kubernetes quantity). |
### Image Registry

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| imagePullSecrets | list of [core/v1.LocalObjectReference](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.core/v1.LocalObjectReference) | `[]` | List of image pull secret names for the container registry. |
| imagePullSecrets[0].name | string | `nil` | Name of the Kubernetes Secret in the same namespace. |
### Image Automation

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| imageUpdate.enabled | bool | `false` | Enable Flux image automation (ImageRepository, ImagePolicy, ImageUpdateAutomation). When false, no Flux image resources are created. Set to true to allow Flux to track images and automatically commit updates to git. |
| imageUpdate.imageTagPattern | string | `"^(?P<ts>[0-9]+)$"` | Regex with named capture group "ts" for chronological tag ordering. |
| imageUpdate.imageUpdateBranch | string | `"main"` | Git branch for ImageUpdateAutomation commits. |
| imageUpdate.messageTemplate | string | `"Automated image update\n\nAutomation name: {{ .AutomationObject }}\n\nFiles:\n{{ range $filename, $_ := .Changed.FileChanges -}}\n- {{ $filename }}\n{{ end -}}\n\nObjects:\n{{ range $resource, $changes := .Changed.Objects -}}\n- {{ $resource.Kind }} {{ $resource.Name }}\n  Changes:\n{{- range $_, $change := $changes }}\n    - {{ $change.OldValue }} -> {{ $change.NewValue }}\n{{ end -}}\n{{ end -}}\n"` | Commit message template for image update automation. |
| imageUpdate.updatePath | string | `"."` | Repo-relative path scanned for `$imagepolicy` annotations. |
### Ingress

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ingress.annotations | object | `{}` | Annotations to add to the Ingress resource (e.g., cert-manager.io/cluster-issuer). |
| ingress.className | string | `""` | Ingress class name (e.g., nginx, avi). |
| ingress.host | string | `""` | Ingress hostname (e.g., app.example.com). |
| ingress.paths | list | `[]` | Multiple path rules. When set, overrides the single targetComponent path. Each entry specifies path, pathType (default: Prefix), and targetComponent. |
| ingress.paths[0].path | string | `nil` | URL path to match (e.g., /api or /). |
| ingress.paths[0].pathType | string | `nil` | Kubernetes path matching type (Prefix, Exact, or ImplementationSpecific). |
| ingress.paths[0].portName | string | `nil` | Name of the Service port to route to. |
| ingress.paths[0].targetComponent | string | `nil` | Component key whose Service receives traffic for this path. |
| ingress.targetComponent | string | `""` | Component key whose Service receives all inbound traffic when a single path `/` routes to one component. |
| ingress.tlsHost | string | `""` | AVI HostRule TLS host for certificate selection. |

### Network Policy

When `networkPolicy.enabled` is `true` (the default), the chart creates a
layered set of NetworkPolicy resources:

#### Default-Deny Policy

The chart creates a `<fullname>-default-deny` NetworkPolicy that denies all
ingress and egress for pods in this release, then re-allows **DNS** (UDP/TCP
port 53). This ensures pods can resolve cluster-internal names.

#### Per-Component Policy

Each component gets a `<fullname>-<name>` NetworkPolicy with `policyTypes:
[Ingress, Egress]`. Egress rules are built as follows:

| Condition                           | Egress Rules                                       |
|-------------------------------------|----------------------------------------------------|
| `injectDatabase: true`              | Database access                                    |
| `serviceLinks` entries              | TCP to each linked sibling component's port        |
| Neither of the above                | **No egress rules beyond DNS** (from default-deny) |
| `extraEgress` entries (always)      | Appended as-is to the egress list                  |

**Components without `injectDatabase` or `serviceLinks` have no egress rules
beyond DNS.** If your component needs to reach external APIs or any other
outbound destination, use `extraEgress`:

```yaml
components:
  myapp:
    extraEgress:
      - to:
          - ipBlock:
              cidr: 10.0.0.0/8
        ports:
          - port: 443
            protocol: TCP
```

[Standard `NetworkPolicyEgressRule` objects are accepted.](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| networkPolicy | object | `{"allowPublicIngress":false,"cnpgOperatorSelector":{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"cnpg-system"}}},"monitoringSelector":{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"monitoring"}}}}` | NetworkPolicy configuration. Omit entirely to skip network policy creation. |
| networkPolicy.allowPublicIngress | bool | `false` | When true, allows ingress from any source (0.0.0.0/0) to the ingress.targetComponent. Only meaningful when ingress.targetComponent is also set. |
| networkPolicy.cnpgOperatorSelector | object | `{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"cnpg-system"}}}` | NetworkPolicyPeer selecting the CloudNativePG operator namespace. Required for CNPG health checks, switchover, and cluster management. |
| networkPolicy.monitoringSelector | object | `{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"monitoring"}}}` | NetworkPolicyPeer selecting the Prometheus monitoring namespace. Traffic from this peer is allowed to reach the database metrics port (9187). |
### Other Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| containerSecurityContext | [core/v1.SecurityContext](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.core/v1.SecurityContext) | drop all capabilities, readonly, nonRoot, no escalation | Container security context. Provides container-level security settings. Individual components can override. Override with {} to remove all defaults. |
| podSecurityContext | [core/v1.PodSecurityContext](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.core/v1.PodSecurityContext) | `{"seccompProfile":{"type":"RuntimeDefault"}}` | Default pod security context, individual components can override with their own podSecurityContext block. |
| resources | [core/v1.ResourceRequirements](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.core/v1.ResourceRequirements) | `{}` | Default resource requests and limits. Individual components can override this. |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account. |
| serviceAccount.automount | bool | `false` | Automatically mount API credentials for the service account. |
| serviceAccount.enabled | bool | `false` | Create a service account for the deployment. |
| serviceAccount.name | string | `""` | Name of the service account to use. Defaults to `<fullname>` when empty. |

