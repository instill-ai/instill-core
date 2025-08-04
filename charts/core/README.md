# core

![Version: 0.1.65](https://img.shields.io/badge/Version-0.1.65-informational?style=flat-square) ![AppVersion: 0.54.0](https://img.shields.io/badge/AppVersion-0.54.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

The Helm chart of Instill Core

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://helm.influxdata.com | influxdb2 | 2.1.1 |
| https://open-telemetry.github.io/opentelemetry-helm-charts | opentelemetry-collector | 0.129.0 |

## Install

Once Helm has been set up correctly, add the repo as follows:

```bash
helm repo add instill-ai https://helm.instill-ai.com
```

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages. You can then run `helm search repo instill-ai/core --devel` to see the charts.

To install the chart:

```bash
helm install <release-name> instill-ai/core --devel
```

## Uninstall

To uninstall the chart:

```bash
helm uninstall <release-name>
```
