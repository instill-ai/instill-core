# vdp

![Version: 0.1.0-alpha](https://img.shields.io/badge/Version-0.1.0--alpha-informational?style=flat-square) ![AppVersion: 0.6.0-alpha](https://img.shields.io/badge/AppVersion-0.6.0--alpha-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Versatile Data Pipeline (VDP) empowers the modern data stack to process unstructured data.

# Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://helm.elastic.co | elasticsearch | 8.5.1 |

## Install

Once Helm has been set up correctly, add the repo as follows:

```bash
helm repo add instill https://helm.instill.tech
```

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo vdp` to see the charts.

To install the chart (alpha version):

```bash
helm install <release-name> instill/vdp --devel
```

## Uninstall

To uninstall the chart:

```bash
helm delete <release-name>
```
