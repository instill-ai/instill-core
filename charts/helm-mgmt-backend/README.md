# mgmt-backend Helm Chart

## Prerequisites

- [pre-commit for helm-docs](https://github.com/norwoodj/helm-docs)

## How to contribute

The `README.md` for the Helm chart will be automatically generated at commit time by the [helm-docs pre-commit hook](https://github.com/norwoodj/helm-docs).
As recommended by the [official Helm doc](https://helm.sh/docs/topics/charts/#the-chart-file-structure), the Helm chart is contained in its own folder, the name of the folder being the name of the Helm chart.

## CI/CD

### Push
In order to automatically version Helm chart, every git `push` to `main` branch will be immediately followed by a chart versioning `commit` pushed into `main` branch again. Each versioning `commit` and `push` will then trigger Helm chart pushing into Chartmuseum repository. With [Release Please Action](https://github.com/google-github-actions/release-please-action), we maintain two types of Helm charts complying [SemVer 2.0](https://semver.org):
1. Core version for release `push`: `<versioncore>`;
2. Build metadata version for non-release `push`: `<versioncore>+<buildmetadata>`

### Pull request
Each git `push` to a feature branch in a pull request (PR) session will trigger a git `commit` on updating build metadata version and git `push` right away to the PR base branch followed by a Helm chart pushing into Chartmuseum repository.

### Chart purge
Two cases:
1. Charts with a build metadata version will be purged every time after a PR is merged (pushed) into `main` branch triggering a chart version update commit. The chart with the latest build metadata version (latest commit) will be kept.

2. All charts with a build metadata version will be purged right after a new release is issued.
