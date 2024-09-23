# Helm Chart Repository

## Prerequisites

 * [Kubernetes](https://kubernetes.io) >= 1.19
 * [Helm](https://helm.sh) >= 3.2.0

## Charts

 * [Static Website](stable/static-website): Static website with no dependencies.

## Usage

```shell
helm repo add eresearchqut https://eresearchqut.github.io/charts
helm search repo eresearchqut
helm install <release> eresearchqut/<chart>
```
