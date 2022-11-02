# triton-backend Helm Chart

- [triton-backend Helm Chart](#triton-backend-helm-chart)
- [Prerequisites](#prerequisites)
- [How to upgrade to new Triton versions](#how-to-upgrade-to-new-triton-versions)
- [Manually manage Helm Charts in Harbor](#manually-manage-helm-charts-in-harbor)
  - [Preparations](#preparations)
  - [[**Recommended**] Manage with the ChartMuseum](#recommended-manage-with-the-chartmuseum)
  - [Manage with the OCI-compatible registry](#manage-with-the-oci-compatible-registry)
- [How to contribute](#how-to-contribute)


# Prerequisites

- [pre-commit for helm-docs](https://github.com/norwoodj/helm-docs)
- [Helm v3](https://helm.sh/)
- [Harbor registry 2.0.0](https://goharbor.io/)


# How to upgrade to new Triton versions
Triton maintains an official helm chart in its [repo](https://github.com/NVIDIA/triton-inference-server/tree/master/deploy/single_server). We provide a script `pull_official_helm_chart.sh` to fetch the official helm chart from a given release tag ([default: v2.4.0](https://github.com/triton-inference-server/server/tree/v2.4.0/deploy/single_server)) and put it into `official_single_server_{tag}`.

``` bash
$ ./pull_official_helm_chart.sh -t [tag]
```
where
- `tag` is the release tag that includes the helm chart with the Triton version you want.

However, the official Triton helm chart is out-of-date and *not* ready for use:

- Use Helm v2 instead of Helm v3
- Only compatible with k8s version lower than 1.16. Higher version of v8s leads to helm error [issue](https://github.com/NVIDIA/triton-inference-server/issues/1835).
- As the [official document](https://github.com/NVIDIA/triton-inference-server/tree/master/deploy/single_server) mentioned, `templates/deployment.yaml` has to be modified to use Google Cloud Storage as model repository. Using locally accessible file-system as model repository requires similar modification.

Therefore, we don't directly use the official helm chart, but use it as building blocks to write out own helm charts in **`single_server`**. Don't use the `pull_official_helm_chart.sh` script except when a new version of the chart is available and we want to check and compare with our own maintained charts.

# Manually manage Helm Charts in Harbor

> Note: This section describes how to manually manage Helm Charts with Harbor in case this is needed. In practice, the Helm Chart will be automatically uploaded to Harbor after each release is published, using Github Actions.

There are two places to [manage Helm charts in Harbor](https://goharbor.io/docs/2.0.0/working-with-projects/working-with-images/managing-helm-charts/):
- [**Recommended**] The [ChartMuseum](https://github.com/chartmuseum)
- The OCI-compatible registry, in which helm charts are managed alongside container images

Even though the [ChartMuseum might be deprecated in future](https://github.com/goharbor/harbor/pull/12638), the Terraform Helm provider and Helm v3 have no support for [`helm install` from an OCI registry](https://github.com/hashicorp/terraform-provider-helm/issues/396) yet. We thus recommend to manage Helm Charts with the ChartMuseum for now.

## Preparations
If a chart depends on other charts, before uploading it:
```bash
$ cd <folder with Chart.yaml>
$ helm dependency update
```
It will retrieve all the dependent charts and store them as chart archives in the `charts/` directory.

## [**Recommended**] Manage with the ChartMuseum
Harbor provides the ChartMuseum since version 1.6.0.

Helm charts can be uploaded to Harbor with `push_to_chartmuseum.sh`:
```bash
$ ./push_to_chartmuseum.sh -u [harbor_username] -k [harbor_cli_key]
```
where
- `harbor_username` is your username to login to Harbor
- `harbor_cli_key` is your Harbor CLI key

## Manage with the OCI-compatible registry
Harbor supports the [Open Container Initiative (OCI)](https://opencontainers.org/) registry since version 2.0.0 and Helm supports OCI for package distribution since version 3.

Helm charts can be saved locally and pushed to our Harbor repository with `push_to_oci_registry.sh`:
```bash
$ ./push_to_oci_registry.sh -u [harbor_username] -k [harbor_cli_key]
```
where
- `harbor_username` is your username to login to Harbor
- `harbor_cli_key` is your Harbor CLI key

To pull from Harbor repository with `pull_from_oci_registry`:
```bash
$ ./pull_from_oci_registry.sh -u [harbor_username] -k [harbor_cli_key] -d [export_directory]
```
where
- `harbor_username` is your username to login to Harbor
- `harbor_cli_key` is your Harbor CLI key
- `export_directory` is the directory to export the chart.

The chart will be exported to `<export_directory>/<chart_name>`. In this case, `./triton-inference-server` by default.


# How to contribute

The `README.md` for the Helm Chart will be automatically generated at commit time by the [helm-docs pre-commit hook](https://github.com/norwoodj/helm-docs).
As recommended by the [official Helm doc](https://helm.sh/docs/topics/charts/#the-chart-file-structure), the Helm Chart is contained in its own folder separate folder, the name of the folder being the name of the Helm Chart.

Before releasing a new version, make sure that the `Chart.yml` contains the same version as the one that is going to be released. Once the Github release is published, the Helm Chart will be automatically uploaded to our Harbor registry. How to increment the version of the Helm Chart is described in [ClickUp](https://app.clickup.com/2564371/v/dc/2e88k-302/2e88k-1359).
