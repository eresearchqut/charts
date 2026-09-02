# component-based-app

![Version: 0.3.1](https://img.shields.io/badge/Version-0.3.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Generic library chart for a research application deployment.

## Prerequisites

When using the database, the following prerequisites are required.

1. The namespace must have the label `app/managed-by: cnpg-operator` for CNPG
   to discover and manage the database cluster.
2. For backups, an existing Secret with `ACCESS_KEY_ID`/`ACCESS_SECRET_KEY` referenced by `database.backups.secret.name`.

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

### AVI

When `avi.enabled` is `true`, the chart renders an AVI `HostRule`/`HTTPRule` pair
(`ako.vmware.com`) for every entry in `ingress.hosts`, so each host gets its own
virtualhost-level configuration.

`avi.hostRule` and `avi.httpRule` set the defaults applied to every host. A host
may override any of them under its own `avi:` block:

```yaml
ingress:
  enabled: true
  hosts:
    - host: app.example.com
      avi:
        sslKeyCertificate: app-example-com-cert   # defaults to unset (insecure) when omitted
        applicationProfile: Custom-HTTP           # defaults to avi.hostRule.applicationProfile
        policySets: ["internal-only"]             # defaults to avi.hostRule.policySets
        healthMonitors: ["Custom-HTTP"]           # defaults to avi.httpRule.healthMonitors
        loadBalancerPolicy:
          algorithm: LB_ALGORITHM_ROUND_ROBIN      # defaults to avi.httpRule.loadBalancerPolicy.algorithm
      paths:
        - path: /
          targetComponent: web
avi:
  enabled: true
```

Every field under a host's `avi:` block is optional and falls back to the
matching `avi.hostRule`/`avi.httpRule` default, so most hosts need none of
this and only unusual ones (a different certificate, a stricter policy set,
a dedicated health monitor) set overrides.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| avi.enabled | bool | `false` | Create AVI HostRule/HTTPRule resources for each ingress host. |
| avi.hostRule | object | `{"applicationProfile":"System-HTTP","policySets":["geo-blocking-default","ip-reputation-block-all","robots-disallow-all"]}` | HostRule (virtualhost-level) defaults, applied to every host unless overridden per host under `ingress.hosts`. |
| avi.hostRule.applicationProfile | string | `"System-HTTP"` | AVI HostRule application profile name. |
| avi.hostRule.policySets | list | `["geo-blocking-default", "ip-reputation-block-all", "robots-disallow-all"]` | Default AVI HostRule policy sets, applied to every host unless a host sets its own `ingress.hosts[].policySets`. |
| avi.httpRule | object | `{"healthMonitors":["System-HTTP"],"loadBalancerPolicy":{"algorithm":"LB_ALGORITHM_LEAST_CONNECTIONS"}}` | HTTPRule (pool-level) defaults, applied to every host. |
| avi.httpRule.healthMonitors | list | `["System-HTTP"]` | AVI HTTPRule health monitors. |
| avi.httpRule.loadBalancerPolicy.algorithm | string | `"LB_ALGORITHM_LEAST_CONNECTIONS"` | AVI HTTPRule load balancer algorithm. |

### Components

Used to create deployment-service-ingress-netpol combination. Designed to encapsulate a
"component" of the application, for example the "backend" or "frontend" or even a "worker"

Component keys must be valid Kubernetes DNS label names (lowercase alphanumeric + hyphens).

Every component requires at minimum `image.repository`, `image.tag`, `port`, and
`command`.

Adding extras such as liveness/readiness probes is recommended.

Components named by an `ingress.hosts[].paths[].targetComponent` receive a `FQDN` environment variable set to the comma-separated list of hosts that route to them.

#### Application Secrets

Each component can reference secrets via `appSecretKeys`. The values are from the secret in `components.*.secretName`. Each `appSecretKeys` entry maps a secret key to an environment variable:

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| components.* | object | `{}` | Application component, key must be a valid kubernetes dns label |
| components.*.affinity | [core/v1.Affinity](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.core/v1.Affinity) | `nil` | Affinity and anti-affinity rules for pod scheduling. |
| components.*.allowDatabaseAccess | bool | `nil` | When true, injects `DB_USERNAME`, `DB_PASSWORD`, `DB_HOST`, and `DB_PORT` from the database secret. |
| components.*.allowedFQDNs | list | `[]` | Allow egress to external destinations by FQDN instead of IP address. Renders an Antrea-native NetworkPolicy (crd.antrea.io) whose Allow rules take precedence over the IP-based Kubernetes NetworkPolicies. Requires the Antrea CNI. Only meaningful when `networkPolicy` is enabled. |
| components.*.allowedHostsEnvName | string | `nil` | Environment variable set to `<service-name>,$(POD_IP),$(NODE_IP),<ingress.hosts[*].host>`. Every configured ingress host is appended, comma-separated. |
| components.*.appSecretKeys | list | `nil` | Environment variables sourced from a Kubernetes Secret. |
| components.*.appSecretKeys[0].envName | string | `nil` | Name of the environment variable exposed to the container. |
| components.*.appSecretKeys[0].secretKey | string | `nil` | Key within the referenced Kubernetes Secret. |
| components.*.automountServiceAccountToken | bool | `nil` | Overrides serviceAccount.automount for this component's pods. |
| components.*.command | list | `[]` | Command and arguments passed to the container (overrides image ENTRYPOINT). |
| components.*.configMaps | object | `nil` | ConfigMaps rendered for this component, keyed by ConfigMap name; each value is a data map of file name to content. A checksum/config Pod annotation is derived from these so config changes trigger a rollout. |
| components.*.containerSecurityContext | [core/v1.SecurityContext](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.core/v1.SecurityContext) | `nil` | Per-component container security context. Overrides the global `containerSecurityContext`. Set to `{}` to opt out. |
| components.*.env | list of [core/v1.EnvVar](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.core/v1.EnvVar) | `[]` | Additional environment variables in Kubernetes EnvVar format. |
| components.*.envFrom | list of [core/v1.EnvFromSource](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.core/v1.EnvFromSource) | `[]` | Additional environment variables in Kubernetes EnvFromSource format. |
| components.*.extraEgress | list of [networking/v1.NetworkPolicyEgressRule](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.networking/v1.NetworkPolicyEgressRule) | `[]` | Additional NetworkPolicy egress rules. Only meaningful when `networkPolicy` is configured. |
| components.*.extraIngress | list of [networking/v1.NetworkPolicyIngressRule](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.networking/v1.NetworkPolicyIngressRule) | `[]` | Additional NetworkPolicy ingress rules. Only meaningful when `networkPolicy` is configured. |
| components.*.image | object | `nil` | Container image reference. |
| components.*.image.repository | string | `nil` | Container image repository (e.g., registry.example.com/myapp). |
| components.*.image.tag | string | `nil` | Container image tag. Required — no default is applied. |
| components.*.imagePullSecrets | list of [core/v1.LocalObjectReference](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.core/v1.LocalObjectReference) | `[]` | Image pull secrets used by this component's Pods. When image automation is enabled, the first secret is used by this component's ImageRepository. |
| components.*.imagePullSecrets[0].name | string | `nil` | Name of the Kubernetes Secret in the same namespace. |
| components.*.initContainer | object | `nil` | Init container that runs before the main container. Uses the same image as the component. |
| components.*.initContainer.command | list | `nil` | Init container command and arguments. |
| components.*.initContainer.containerSecurityContext | [core/v1.SecurityContext](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.core/v1.SecurityContext) | `nil` | Security context for the init container only. Overrides the component's `containerSecurityContext` for this container. Unlike it, `runAsUser`/`runAsGroup` are permitted here — e.g. for a one-shot root chown of a volume before the non-root main container starts. |
| components.*.livenessProbe | object | `nil` | Container liveness probe. Omit the block to disable. |
| components.*.livenessProbe.failureThreshold | int | `nil` | Consecutive failures before restart. |
| components.*.livenessProbe.initialDelaySeconds | int | `nil` | Delay before first probe. |
| components.*.livenessProbe.path | string | `nil` | HTTP path for the liveness probe (e.g., /healthz). |
| components.*.livenessProbe.periodSeconds | int | `nil` | Interval between probes. |
| components.*.livenessProbe.terminationGracePeriodSeconds | int | `nil` | Grace period for pod shutdown after the probe fails. Falls back to the pod-level grace period when unset. |
| components.*.livenessProbe.timeoutSeconds | int | `nil` | Probe timeout. |
| components.*.monitoring | object | `nil` | Prometheus ServiceMonitor configuration. Requires prometheus-operator. Omit to disable. |
| components.*.monitoring.interval | string | `nil` | Prometheus scrape interval. |
| components.*.monitoring.path | string | `nil` | HTTP path for the metrics endpoint. |
| components.*.monitoring.port | string | `nil` | Name of the port exposing metrics on the Service. |
| components.*.monitoring.scrapeTimeout | string | `nil` | Prometheus scrape timeout. |
| components.*.nodeIPEnvName | string | `nil` | Name of the environment variable that receives the node's IP via the Downward API. Used by allowed hosts as `NODE_IP` when omitted. |
| components.*.nodeSelector | object | `nil` | Node labels for pod assignment. |
| components.*.podAnnotations | object | `nil` | Annotations added to the component's Pod. |
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
| components.*.serviceAccountName | string | `nil` | ServiceAccount used by this component's pods. Falls back to the release-level serviceAccount name ("default" when serviceAccount.enabled is false). |
| components.*.serviceLinks | list | `nil` | Injects HTTP URLs pointing to sibling component Services as environment variables. |
| components.*.serviceLinks[0].envName | string | `nil` | Name of the environment variable that receives the URL. |
| components.*.serviceLinks[0].path | string | `nil` | URL path appended to the service URL. |
| components.*.serviceLinks[0].targetName | string | `nil` | Key of the target component in this chart. |
| components.*.startupProbe | object | `nil` | Startup probe for slow-starting applications. Set `path` to enable; omit to disable. |
| components.*.startupProbe.failureThreshold | int | `nil` | Consecutive failures before the container is killed. Defaults higher (30) for slow starts. |
| components.*.startupProbe.initialDelaySeconds | int | `nil` | Delay before first probe. |
| components.*.startupProbe.path | string | `nil` | HTTP path for the startup probe. Empty string disables it. |
| components.*.startupProbe.periodSeconds | int | `nil` | Interval between probes. |
| components.*.startupProbe.terminationGracePeriodSeconds | int | `nil` | Grace period for pod shutdown after the probe fails. Falls back to the pod-level grace period when unset. |
| components.*.startupProbe.timeoutSeconds | int | `nil` | Probe timeout. |
| components.*.tolerations | list of [core/v1.Toleration](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.core/v1.Toleration) | `[]` | Tolerations for pod scheduling onto tainted nodes. |
| components.*.volumeMounts | list of [core/v1.VolumeMount](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.core/v1.VolumeMount) | `[]` | Additional volume mounts into the component's main container. |
| components.*.volumes | list of [core/v1.Volume](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.core/v1.Volume) | `[]` | Additional volumes attached to the component's Pod. |

### Database

The database is the upstream [CloudNativePG `cluster` chart](https://github.com/cloudnative-pg/charts/tree/cluster-v0.8.1/charts/cluster)
(cloudnative-pg/charts), mounted as a Helm dependency aliased `database` and version-pinned
in `Chart.yaml`. Every value under `database.*` except `enabled` is forwarded verbatim to the
subchart — see the [pinned `cluster-v0.8.1` values reference](https://github.com/cloudnative-pg/charts/blob/cluster-v0.8.1/charts/cluster/values.yaml)
for the full set of options.

#### Infra defaults

This chart layers the following defaults over the upstream chart (all overridable per-release):

| Concern | Default |
|---|---|
| Image | `registry.eres.qut.edu.au/ghcr/cloudnative-pg/postgresql:17` (mirror registry) |
| Instances | 1 |
| Storage | `vsan-file`, 8Gi; `walStorage` enabled, 2Gi `vsan-file` |
| Resources | 0.5→1 CPU, 256Mi→1Gi |
| Anti-affinity | enabled, `topologyKey: kubernetes.io/hostname` |
| Monitoring | PodMonitor on, PrometheusRule off |
| initdb | `dataChecksums: true`, `walSegmentSize: 32` |
| Backups | barman-cloud plugin method, S3 `ap-southeast-2`, existing Secret credentials, `walMaxParallel: 32`, 14d retention, daily 04:00 schedule |

#### Credentials

CNPG auto-generates the app database (`app`), owner (`app`), and a `kubernetes.io/basic-auth`
secret named `<cluster>-app` unless `database.cluster.initdb.secret.name` points at an existing
secret. When supplying your own secret, its `username` key must equal `cluster.initdb.owner`
(which defaults to the database name).

#### Connecting

The cluster is named `<release>-database` by default (`database.fullnameOverride` to change it).
Components with `allowDatabaseAccess: true` reach it at `<cluster>-rw:5432` via the injected
`DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD` environment variables.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| database | object | `{"backups":{"destinationPath":"","enabled":false,"endpointURL":"https://s3.ap-southeast-2.amazonaws.com/","method":"plugin","pluginConfiguration":{"name":"barman-cloud.cloudnative-pg.io"},"provider":"s3","retentionPolicy":"14d","secret":{"create":false,"name":""},"wal":{"maxParallel":32}},"cluster":{"affinity":{"enablePodAntiAffinity":true,"topologyKey":"kubernetes.io/hostname"},"imageName":"registry.eres.qut.edu.au/ghcr/cloudnative-pg/postgresql:17","initdb":{"dataChecksums":true,"walSegmentSize":32},"instances":1,"monitoring":{"enabled":true,"prometheusRule":{"enabled":false}},"resources":{"limits":{"cpu":"1","memory":"1Gi"},"requests":{"cpu":"0.5","memory":"256Mi"}},"storage":{"size":"8Gi","storageClass":"vsan-file"},"walStorage":{"enabled":true,"size":"2Gi","storageClass":"vsan-file"}},"enabled":false}` | CloudNativePG `cluster` subchart passthrough (cloudnative-pg/charts, pinned in Chart.yaml). All keys except `enabled` are forwarded verbatim to the subchart; see https://github.com/cloudnative-pg/charts/tree/cluster-v0.8.1/charts/cluster for the full reference. This chart layers infra defaults (all documented below): mirror-registry image, vsan-file storage classes, 1 instance, pod anti-affinity, PodMonitor on (PrometheusRule off), per-instance resource requests/limits, barman-cloud plugin backups (S3 ap-southeast-2, existing-secret credentials, 14d retention, daily 04:00 schedule). |
| database.backups | object | `{"destinationPath":"","enabled":false,"endpointURL":"https://s3.ap-southeast-2.amazonaws.com/","method":"plugin","pluginConfiguration":{"name":"barman-cloud.cloudnative-pg.io"},"provider":"s3","retentionPolicy":"14d","secret":{"create":false,"name":""},"wal":{"maxParallel":32}}` | Backup configuration (barman-cloud plugin to S3), forwarded to the subchart's `backups` values. The keys below are this chart's layered infra defaults; any upstream key may be added. |
| database.backups.destinationPath | string | `""` | S3 destination for backups. Required when enabled, e.g. s3://eresearch-k8s-postgres-backup/<app>-<env>-backup |
| database.backups.enabled | bool | `false` | Enable automated backups. Requires destinationPath and secret.name. |
| database.backups.endpointURL | string | `"https://s3.ap-southeast-2.amazonaws.com/"` | Object store endpoint. |
| database.backups.method | string | `"plugin"` | Backup method; `plugin` uses the barman-cloud ObjectStore. |
| database.backups.pluginConfiguration | object | `{"name":"barman-cloud.cloudnative-pg.io"}` | barman-cloud plugin reference. |
| database.backups.pluginConfiguration.name | string | `"barman-cloud.cloudnative-pg.io"` | Plugin name. |
| database.backups.provider | string | `"s3"` | Object store provider. |
| database.backups.retentionPolicy | string | `"14d"` | How long backups are retained. |
| database.backups.secret | object | `{"create":false,"name":""}` | Object store credentials. |
| database.backups.secret.create | bool | `false` | Create the credentials Secret from values instead of referencing an existing one. |
| database.backups.secret.name | string | `""` | Existing Secret with ACCESS_KEY_ID / ACCESS_SECRET_KEY. Required when backups are enabled. |
| database.backups.wal | object | `{"maxParallel":32}` | WAL archiving. |
| database.backups.wal.maxParallel | int | `32` | Maximum parallel WAL archive/restore operations. |
| database.cluster | object | `{"affinity":{"enablePodAntiAffinity":true,"topologyKey":"kubernetes.io/hostname"},"imageName":"registry.eres.qut.edu.au/ghcr/cloudnative-pg/postgresql:17","initdb":{"dataChecksums":true,"walSegmentSize":32},"instances":1,"monitoring":{"enabled":true,"prometheusRule":{"enabled":false}},"resources":{"limits":{"cpu":"1","memory":"1Gi"},"requests":{"cpu":"0.5","memory":"256Mi"}},"storage":{"size":"8Gi","storageClass":"vsan-file"},"walStorage":{"enabled":true,"size":"2Gi","storageClass":"vsan-file"}}` | Configuration of the PostgreSQL cluster, forwarded to the subchart's `cluster` values. The keys below are this chart's layered infra defaults; any upstream key may be added. |
| database.cluster.affinity | object | `{"enablePodAntiAffinity":true,"topologyKey":"kubernetes.io/hostname"}` | Pod affinity/anti-affinity for the PostgreSQL pods. |
| database.cluster.affinity.enablePodAntiAffinity | bool | `true` | Spread instances across the topology domain. |
| database.cluster.affinity.topologyKey | string | `"kubernetes.io/hostname"` | Topology domain used for pod anti-affinity. |
| database.cluster.imageName | string | `"registry.eres.qut.edu.au/ghcr/cloudnative-pg/postgresql:17"` | PostgreSQL operand image (mirrored from ghcr.io/cloudnative-pg/postgresql). |
| database.cluster.initdb | object | `{"dataChecksums":true,"walSegmentSize":32}` | Bootstrap of a newly created cluster. CNPG additionally defaults database and owner to "app" and creates secret "<cluster>-app" unless overridden here. |
| database.cluster.initdb.dataChecksums | bool | `true` | Enable page checksums. |
| database.cluster.initdb.walSegmentSize | int | `32` | WAL segment size in MB. |
| database.cluster.instances | int | `1` | Number of PostgreSQL instances. |
| database.cluster.monitoring | object | `{"enabled":true,"prometheusRule":{"enabled":false}}` | Prometheus monitoring for the cluster (PodMonitor). |
| database.cluster.monitoring.enabled | bool | `true` | Enable monitoring (PodMonitor). |
| database.cluster.monitoring.prometheusRule | object | `{"enabled":false}` | Default alert rules. |
| database.cluster.monitoring.prometheusRule.enabled | bool | `false` | Create the default PrometheusRule alerts. |
| database.cluster.resources | object | `{"limits":{"cpu":"1","memory":"1Gi"},"requests":{"cpu":"0.5","memory":"256Mi"}}` | Compute resources for the PostgreSQL pods. |
| database.cluster.resources.limits | object | `{"cpu":"1","memory":"1Gi"}` | Resource limits. |
| database.cluster.resources.limits.cpu | string | `"1"` | Maximum CPU. |
| database.cluster.resources.limits.memory | string | `"1Gi"` | Maximum memory. |
| database.cluster.resources.requests | object | `{"cpu":"0.5","memory":"256Mi"}` | Resource requests. |
| database.cluster.resources.requests.cpu | string | `"0.5"` | Requested CPU. |
| database.cluster.resources.requests.memory | string | `"256Mi"` | Requested memory. |
| database.cluster.storage | object | `{"size":"8Gi","storageClass":"vsan-file"}` | Primary data volume. |
| database.cluster.storage.size | string | `"8Gi"` | Data volume size. |
| database.cluster.storage.storageClass | string | `"vsan-file"` | Data volume StorageClass. |
| database.cluster.walStorage | object | `{"enabled":true,"size":"2Gi","storageClass":"vsan-file"}` | Separate WAL volume. |
| database.cluster.walStorage.enabled | bool | `true` | Enable a dedicated WAL volume. |
| database.cluster.walStorage.size | string | `"2Gi"` | WAL volume size. |
| database.cluster.walStorage.storageClass | string | `"vsan-file"` | WAL volume StorageClass. |
| database.enabled | bool | `false` | Enable or disable the CloudNativePG PostgreSQL database cluster. |
### Image Automation

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| imageUpdate.enabled | bool | `false` | Enable Flux image automation (ImageRepository, ImagePolicy, ImageUpdateAutomation). When false, no Flux image resources are created. Set to true to allow Flux to track images and automatically commit updates to git. |
| imageUpdate.imageTagPattern | string | `"^(?P<ts>[0-9]+)$"` | Regex with named capture group "ts" for chronological tag ordering. |
| imageUpdate.messageTemplate | string | `"Automated image update\n\nAutomation name: {{ .AutomationObject }}\n\nFiles:\n{{ range $filename, $_ := .Changed.FileChanges -}}\n- {{ $filename }}\n{{ end -}}\n\nObjects:\n{{ range $resource, $changes := .Changed.Objects -}}\n- {{ $resource.Kind }} {{ $resource.Name }}\n  Changes:\n{{- range $_, $change := $changes }}\n    - {{ $change.OldValue }} -> {{ $change.NewValue }}\n{{ end -}}\n{{ end -}}\n"` | Commit message template for image update automation. |
| imageUpdate.repository | object | `{"branch":"main","name":"","namespace":"flux-system"}` | Flux GitRepository source used by ImageUpdateAutomation. |
| imageUpdate.repository.branch | string | `"main"` | Git branch checked out by ImageUpdateAutomation. |
| imageUpdate.repository.name | string | `""` | Name of the Flux GitRepository used as ImageUpdateAutomation sourceRef.name. |
| imageUpdate.repository.namespace | string | `"flux-system"` | Namespace of the Flux GitRepository used as ImageUpdateAutomation sourceRef.namespace. |
| imageUpdate.updatePath | string | `"."` | Repo-relative path scanned for `$imagepolicy` annotations. |
### Ingress

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ingress.annotations | object | `{}` | Annotations to add to the Ingress resource (e.g., cert-manager.io/cluster-issuer). |
| ingress.className | string | `""` | Ingress class name (e.g., nginx, avi). |
| ingress.enabled | bool | `false` | Create the Ingress resource. |
| ingress.hosts | list | `[]` | Hosts to route. Each entry renders one `rules` entry on the Ingress; when `avi.enabled` is true, each host also gets its own AVI HostRule/HTTPRule pair. |
| ingress.hosts[0].avi | object | `nil` | Per-host overrides for this host's AVI HostRule/HTTPRule. Every field falls back to the matching `avi.hostRule`/`avi.httpRule` default when omitted. Only used when `avi.enabled` is true. |
| ingress.hosts[0].avi.applicationProfile | string | `nil` | AVI HostRule application profile name. Falls back to `avi.hostRule.applicationProfile`. |
| ingress.hosts[0].avi.healthMonitors | list | `nil` | AVI HTTPRule health monitors. Falls back to `avi.httpRule.healthMonitors`. |
| ingress.hosts[0].avi.loadBalancerPolicy | object | `nil` | AVI HTTPRule load balancer policy. Falls back to `avi.httpRule.loadBalancerPolicy`. |
| ingress.hosts[0].avi.loadBalancerPolicy.algorithm | string | `nil` | AVI HTTPRule load balancer algorithm. |
| ingress.hosts[0].avi.policySets | list | `nil` | AVI HostRule policy sets. Falls back to `avi.hostRule.policySets`. |
| ingress.hosts[0].avi.sslKeyCertificate | string | `nil` | AVI HostRule certificate reference name. Omit to leave the virtualhost insecure (HTTP only); has no global default. |
| ingress.hosts[0].host | string | `nil` | Ingress hostname (e.g., app.example.com). |
| ingress.hosts[0].paths | list | `nil` | Path rules for this host. |
| ingress.hosts[0].paths[0].path | string | `nil` | URL path to match (e.g., /api or /). |
| ingress.hosts[0].paths[0].pathType | string | `nil` | Kubernetes path matching type (Prefix, Exact, or ImplementationSpecific). |
| ingress.hosts[0].paths[0].portName | string | `nil` | Name of the Service port to route to. |
| ingress.hosts[0].paths[0].targetComponent | string | `nil` | Component key whose Service receives traffic for this path. |
| ingress.tls | list | `[]` | Standard Kubernetes Ingress `tls` block (secret-based). Independent of AVI's `sslKeyCertificate` reference, and only meaningful with an ingress controller that consumes it (e.g. nginx). |

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
| `allowDatabaseAccess: true`         | Database access                                    |
| `serviceLinks` entries              | TCP to each linked sibling component's port        |
| Neither of the above                | **No egress rules beyond DNS** (via default-deny)  |
| `extraEgress` entries (always)      | Appended as-is to the egress list                  |

If your component needs to reach external APIs or any other
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

#### FQDN Egress (Antrea)

To allow egress by domain name instead of IP address, set `allowedFQDNs` on a
component. This renders an Antrea-native `NetworkPolicy` (`crd.antrea.io`) whose
`Allow` rules are evaluated before the IP-based Kubernetes NetworkPolicies and
thus take precedence. Requires the Antrea CNI with the `AntreaPolicy` feature
gate; DNS resolution is already permitted by the default-deny policy.

```yaml
components:
  myapp:
    allowedFQDNs:
      - fqdn: "*.googleapis.com"
        ports:
          - port: 443
            protocol: TCP
      - fqdn: "api.example.com"   # omit ports to allow all ports
```

#### Database Ingress

When `database.enabled` is `true`, the CNPG cluster's pods (`cnpg.io/cluster`
label) only accept inbound PostgreSQL (5432) traffic from:

- Components with `allowDatabaseAccess: true`.
- This chart's own `component-based-app-db-test-connection` Helm test hook
  (`app.kubernetes.io/component: database`).
- The upstream cnpg `cluster` chart's built-in ping-test Helm hook
  (`app.kubernetes.io/component: database-ping-test`), so `helm test` passes
  out of the box.
- `networkPolicy.monitoringSelector` (metrics, port 9187) and
  `networkPolicy.cnpgOperatorSelector` (cluster management).
- Other pods in the same CNPG cluster (replication).

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| networkPolicy | object | `{"cnpgOperatorSelector":{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"cnpg-system"}}},"databaseExtraEgress":[],"enabled":true,"monitoringSelector":{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"monitoring"}}}}` | NetworkPolicy configuration |
| networkPolicy.cnpgOperatorSelector | object | `{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"cnpg-system"}}}` | NetworkPolicyPeer selecting the CloudNativePG operator namespace. Required for CNPG health checks, switchover, and cluster management. |
| networkPolicy.databaseExtraEgress | list of [networking/v1.NetworkPolicyEgressRule](https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.3/_definitions.json#/definitions/io.k8s.api.networking/v1.NetworkPolicyEgressRule) | `[]` | Additional NetworkPolicy egress rules appended to the database NetworkPolicy. Only meaningful when database is enabled. Standard Kubernetes NetworkPolicyEgressRule format (e.g., S3 for WAL archiving). |
| networkPolicy.enabled | bool | `true` | Enable or disable all NetworkPolicy resources for this release. |
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

