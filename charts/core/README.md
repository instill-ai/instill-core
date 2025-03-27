# core

![Version: 0.1.55-beta](https://img.shields.io/badge/Version-0.1.55--beta-informational?style=flat-square) ![AppVersion: 0.49.0-beta](https://img.shields.io/badge/AppVersion-0.49.0--beta-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

The Helm chart of Instill Core

# Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://helm.elastic.co | elasticsearch | 7.17.3 |
| https://helm.influxdata.com | influxdb2 | 2.1.1 |
| https://jaegertracing.github.io/helm-charts | jaeger | 3.4.1 |
| https://open-telemetry.github.io/opentelemetry-helm-charts | opentelemetry-collector | 0.119.0 |
| https://prometheus-community.github.io/helm-charts | kube-prometheus-stack | 70.3.0 |
| https://ray-project.github.io/kuberay-helm/ | kuberay-operator | 1.1.1 |
| https://zilliztech.github.io/milvus-helm/ | milvus | 4.1.30 |

## Install

Once Helm has been set up correctly, add the repo as follows:

```bash
helm repo add instill-ai https://helm.instill-ai.dev
```

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages. You can then run `helm search repo instill-ai/core --devel` to see the charts.

To install the chart (alpha version):

```bash
helm install <release-name> instill-ai/vdp --devel
```

## Uninstall

To uninstall the chart:

```bash
helm uninstall <release-name>
```
