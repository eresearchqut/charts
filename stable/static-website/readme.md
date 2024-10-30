# static-website

![Version: 0.2.1](https://img.shields.io/badge/Version-0.2.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.2.1](https://img.shields.io/badge/AppVersion-0.2.1-informational?style=flat-square)

A Helm chart for deploying simple static websites.

## Installing the Chart

To install this chart with the release name `static-website`:

```console
$ helm repo add eresearchqut https://eresearchqut.github.io/charts/
$ helm install static-website eresearchqut/static-website
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity |
| autoscaling.enabled | bool | `false` | Enable autoscaling |
| autoscaling.maxReplicas | int | `10` | Max number of replicas |
| autoscaling.minReplicas | int | `1` | Min number of replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization |
| autoscaling.targetMemoryUtilizationPercentage | int | `80` | Target memory utilization |
| avi.enabled | bool | `false` | Enable Avi ingress controller |
| avi.hostRule.sslKeyCertificate | string | `""` | Avi Virtual Host certificate name. If not provided, it will use the ingress host name. |
| avi.httpRule.healthMonitors | list | `["System-Ping"]` | List of health monitors |
| avi.httpRule.loadBalancerPolicy.algorithm | string | `"LB_ALGORITHM_LEAST_CONNECTIONS"` | Load balancer policy algorithm |
| containerSecurityContext | object | `{}` | Container security context |
| env | list | `[]` | List of additional environment variables |
| envFrom | list | `[]` | List of additional environment variables from a ConfigMap |
| fullnameOverride | string | `""` | Helm release full name override |
| image.imageOverride | string | `""` | image override name:tag |
| image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| image.repository | string | `"nginx"` | image repository |
| image.tag | string | `"latest"` | image tag |
| imagePullSecrets | list | `[]` | Image pull secrets |
| ingress.annotations | object | `{}` | Annotations to be added to the ingress |
| ingress.className | string | `""` | Ingress class name |
| ingress.enabled | bool | `false` | Create ingress resources |
| ingress.hosts | list | `[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` | Hosts and path for the ingress |
| ingress.tls | list | `[]` | TLS configuration for the ingress |
| nameOverride | string | `""` | Helm release name override |
| networkPolicy.defaultDeny | bool | `true` | Create default deny all network policy |
| networkPolicy.enabled | bool | `true` | Create NetworkPolicy resources |
| networkPolicy.extraEgress | list | `[]` | List of extra egress rules |
| networkPolicy.extraIngress | list | `[]` | List of extra ingress rules |
| nodeSelector | object | `{}` | Node selector |
| podAnnotations | object | `{}` | Pod annotations |
| podSecurityContext | object | `{}` | Pod security context |
| replicaCount | int | `1` | Number of replicas to run |
| resources | object | `{}` | Resources requests and limits |
| service.port | int | `80` | Service port |
| service.type | string | `"ClusterIP"` | Service type |
| serviceAccount.annotations | object | `{}` | Service account annotations |
| serviceAccount.create | bool | `true` | Create and mount default service account |
| serviceAccount.name | string | `""` | Service account name |
| tolerations | list | `[]` | Tolerations |

