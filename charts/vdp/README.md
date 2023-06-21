# vdp

![Version: 0.1.9-alpha](https://img.shields.io/badge/Version-0.1.9--alpha-informational?style=flat-square) ![AppVersion: 0.10.2-alpha](https://img.shields.io/badge/AppVersion-0.10.2--alpha-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

The Helm chart of Instill VDP

# Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | etcd | 8.8.1 |
| https://grafana.github.io/helm-charts | grafana | 6.56.6 |
| https://helm.elastic.co | elasticsearch | 7.17.3 |
| https://helm.influxdata.com | influxdb2 | 2.1.1 |
| https://jaegertracing.github.io/helm-charts | jaeger | 0.71.2 |
| https://open-telemetry.github.io/opentelemetry-helm-charts | opentelemetry-collector | 0.59.1 |
| https://prometheus-community.github.io/helm-charts | prometheus | 22.6.2 |

## Install

Once Helm has been set up correctly, add the repo as follows:

```bash
helm repo add instill-ai https://helm.instill.tech
```

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo vdp --devel` to see the charts.

To install the chart (alpha version):

```bash
helm install <release-name> instill-ai/vdp --devel
```

## Uninstall

To uninstall the chart:

```bash
helm uninstall <release-name>
```
