# genai-arcade

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

GenAI Arcade Helm chart for Kubernetes

## Installing the Chart

To install this chart with the release name `genai-arcade`:

```console
$ helm repo add eresearchqut https://eresearchqut.github.io/charts/
$ helm install genai-arcade eresearchqut/genai-arcade
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| api.affinity | object | `{}` | Affinity |
| api.containerSecurityContext | object | `{"capabilities":{"drop":["all"]},"runAsUser":1000}` | Container security context |
| api.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| api.image.repository | string | `"registry.eres.qut.edu.au/ghcr-eresearch/qut-genai-lab/app"` | Image repository |
| api.image.tag | string | `"latest"` | Image tag |
| api.nodeSelector | object | `{}` | Node selector |
| api.podSecurityContext | object | `{"runAsNonRoot":true}` | Pod security context |
| api.replicas | int | `1` | Number of replicas to run |
| api.resources | object | `{}` | Resources requests and limits |
| api.service.port | int | `8000` | Service port |
| api.service.type | string | `"ClusterIP"` | Service type |
| api.tolerations | list | `[]` | Tolerations |
| commonAnnotations | object | `{}` | Annotations to be added to all resources |
| enableNetworkPolicy | bool | `true` | Enable network policy |
| fullnameOverride | string | `""` | Helm release full name override |
| imagePullSecrets | list | `[]` | Image pull secrets |
| ingress.annotations | object | `{}` | Annotations to be added to the ingress |
| ingress.className | string | `""` | Ingress class name |
| ingress.enabled | bool | `false` | Create ingress resources |
| ingress.hosts | list | `[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` | Hosts and path for the ingress |
| ingress.tls | list | `[]` | TLS configuration for the ingress |
| initScript | string | `"#!/bin/bash\n"` |  |
| nameOverride | string | `""` | Helm release name override |
| redis.affinity | object | `{}` | Affinity |
| redis.containerSecurityContext | object | `{"capabilities":{"drop":["all"]},"runAsUser":999}` | Container security context |
| redis.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| redis.image.repository | string | `"redis"` | Image repository |
| redis.image.tag | string | `"8.2.2"` | Image tag |
| redis.nodeSelector | object | `{}` | Node selector |
| redis.podSecurityContext | object | `{"runAsNonRoot":true}` | Pod security context |
| redis.replicas | int | `1` | Number of replicas to run |
| redis.resources | object | `{}` | Resources requests and limits |
| redis.service.port | int | `6379` | Service port |
| redis.service.type | string | `"ClusterIP"` | Service type |
| redis.tolerations | list | `[]` | Tolerations |
| workers | object | `{}` | Worker configurations |

