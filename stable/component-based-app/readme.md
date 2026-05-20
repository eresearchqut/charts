# component-based-app

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Generic library chart for a research application deployment.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| eResearch QUT | <eresearch@qut.edu.au> |  |

## Source Code

* <https://github.com/eresearchqut/charts>

## Requirements

Kubernetes: `>=1.25-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| appVersion | string | `""` | Application version. Defaults to empty (no version label emitted). Set this to tag Deployments with a meaningful version string. |
| components | object | `{}` | Map of named components; each key becomes a Deployment + Service pair. Each entry generates one Deployment and one ClusterIP Service named `<fullname>-<key>`. Component keys must be valid Kubernetes DNS label names (lowercase alphanumeric + hyphens). Omit a component from this map to disable it. |
| containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true}` | Container security context. Provides container-level security settings. Individual components can override with their own containerSecurityContext block. Override with {} to remove all defaults. |
| database | object | `{"extraEgress":[],"image":{"repository":"registry.eres.qut.edu.au/ghcr/cloudnative-pg/postgresql","tag":"17.5"},"instances":1,"resources":{"limits":{"cpu":"1","memory":"1Gi"},"requests":{"cpu":"0.5","memory":"256Mi"}},"secretName":"","storageClass":"","storageSize":"8Gi","walStorageClass":"","walStorageSize":"2Gi"}` | CloudNativePG database configuration. Omit entirely to skip database provisioning. |
| database.extraEgress | list | `[]` | Additional NetworkPolicy egress rules appended to the database NetworkPolicy. Only meaningful when networkPolicy is set. Standard Kubernetes NetworkPolicyEgressRule format (e.g., S3 for WAL archiving). |
| database.image.repository | string | `"registry.eres.qut.edu.au/ghcr/cloudnative-pg/postgresql"` | CloudNativePG PostgreSQL image repository. |
| database.image.tag | string | `"17.5"` | CloudNativePG PostgreSQL image tag (version). |
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
| fullnameOverride | string | `""` | Helm release full name override. |
| global | object | `{}` | Global values for subchart inheritance. Reserved for values shared across subcharts via Helm's global convention. |
| imagePullSecrets | list | `[]` | List of image pull secret names for the container registry. Each entry must be `name: <secret-name>`, matching Kubernetes imagePullSecrets format. |
| imageUpdate | object | `{"imageTagPattern":"^(?P<ts>[0-9]+)$","imageUpdateBranch":"main","messageTemplate":"Automated image update\n\nAutomation name: {{ .AutomationObject }}\n\nFiles:\n{{ range $filename, $_ := .Changed.FileChanges -}}\n- {{ $filename }}\n{{ end -}}\n\nObjects:\n{{ range $resource, $changes := .Changed.Objects -}}\n- {{ $resource.Kind }} {{ $resource.Name }}\n  Changes:\n{{- range $_, $change := $changes }}\n    - {{ $change.OldValue }} -> {{ $change.NewValue }}\n{{ end -}}\n{{ end -}}\n","updatePath":"."}` | Flux ImageUpdateAutomation configuration. Omit entirely to skip image automation. |
| imageUpdate.imageTagPattern | string | `"^(?P<ts>[0-9]+)$"` | Regex with named capture group "ts" for chronological tag ordering. |
| imageUpdate.imageUpdateBranch | string | `"main"` | Git branch for ImageUpdateAutomation commits. |
| imageUpdate.messageTemplate | string | `"Automated image update\n\nAutomation name: {{ .AutomationObject }}\n\nFiles:\n{{ range $filename, $_ := .Changed.FileChanges -}}\n- {{ $filename }}\n{{ end -}}\n\nObjects:\n{{ range $resource, $changes := .Changed.Objects -}}\n- {{ $resource.Kind }} {{ $resource.Name }}\n  Changes:\n{{- range $_, $change := $changes }}\n    - {{ $change.OldValue }} -> {{ $change.NewValue }}\n{{ end -}}\n{{ end -}}\n"` | Commit message template for image update automation. |
| imageUpdate.updatePath | string | `"."` | Repo-relative path scanned for `$imagepolicy` annotations. |
| ingress.annotations | object | `{}` | Annotations to add to the Ingress resource (e.g., cert-manager.io/cluster-issuer). |
| ingress.className | string | `""` | Ingress class name (e.g., nginx, avi). |
| ingress.host | string | `""` | Ingress hostname (e.g., app.example.com). |
| ingress.paths | list | `[]` | Multiple path rules. When set, overrides the single targetComponent path. Each entry specifies path, pathType (default: Prefix), and targetComponent. Example:   paths:     - path: /api       targetComponent: api     - path: /       targetComponent: frontend |
| ingress.targetComponent | string | `""` | Component key whose Service receives all inbound traffic. Used when a single path `/` routes to one component. |
| ingress.tlsHost | string | `""` | AVI HostRule TLS host for certificate selection. |
| nameOverride | string | `""` | Helm release name override. |
| networkPolicy | object | `{"allowPublicIngress":false,"cnpgOperatorSelector":{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"cnpg-system"}}},"monitoringSelector":{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"monitoring"}}}}` | NetworkPolicy configuration. Omit entirely to skip network policy creation. |
| networkPolicy.allowPublicIngress | bool | `false` | When true, allows ingress from any source (0.0.0.0/0) to the ingress.targetComponent. Only meaningful when ingress.targetComponent is also set. |
| networkPolicy.cnpgOperatorSelector | object | `{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"cnpg-system"}}}` | NetworkPolicyPeer selecting the CloudNativePG operator namespace. Required for CNPG health checks, switchover, and cluster management. |
| networkPolicy.monitoringSelector | object | `{"namespaceSelector":{"matchLabels":{"kubernetes.io/metadata.name":"monitoring"}}}` | NetworkPolicyPeer selecting the Prometheus monitoring namespace. Traffic from this peer is allowed to reach the database metrics port (9187). |
| podSecurityContext | object | `{"seccompProfile":{"type":"RuntimeDefault"}}` | Pod security context. Provides pod-level security settings. Individual components can override with their own podSecurityContext block. |
| resources | object | `{}` | Default resource requests and limits applied to all components. Individual components can override with their own resources block. Set to {} to opt out of defaults entirely. |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account. |
| serviceAccount.automount | bool | `false` | Automatically mount API credentials for the service account. Most application pods do not need Kubernetes API access. Defaulting to false reduces the blast radius of a container compromise. Enable when the pod genuinely needs to call the Kubernetes API. |
| serviceAccount.create | bool | `true` | Create a service account for the deployment. |
| serviceAccount.name | string | `""` | Name of the service account to use. Defaults to `<fullname>` when empty. |

