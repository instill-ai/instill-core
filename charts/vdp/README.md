# vdp

![Version: 0.1.12-alpha](https://img.shields.io/badge/Version-0.1.12--alpha-informational?style=flat-square) ![AppVersion: 0.13.0-alpha](https://img.shields.io/badge/AppVersion-0.13.0--alpha-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

The Helm chart of Instill VDP

# Requirements

| Repository | Name | Version |
|------------|------|---------|

## Install

Once Helm has been set up correctly, add the repo as follows:

```bash
helm repo add instill-ai https://helm.instill.tech
```

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages. You can then run `helm search repo vdp --devel` to see the charts.

To install the chart (alpha version):

```bash
helm install <release-name> instill-ai/vdp --devel
```

## Uninstall

To uninstall the chart:

```bash
helm uninstall <release-name>
```
