# Changelog

## [0.54.0](https://github.com/instill-ai/instill-core/compare/helm-chart-v0.1.64...helm-chart-v0.54.0) (2025-07-25)


### Miscellaneous

* **env:** update ARTIFACT_BACKEND_VERSION ([#1329](https://github.com/instill-ai/instill-core/issues/1329)) ([4da4236](https://github.com/instill-ai/instill-core/commit/4da4236b2578d0355e5bf3aa394ecc999569db7e))
* **env:** update PIPELINE_BACKEND_VERSION ([#1330](https://github.com/instill-ai/instill-core/issues/1330)) ([02a62a8](https://github.com/instill-ai/instill-core/commit/02a62a8d2739150eba33ea2c8ecd36ba1e01104f))
* **helm:** add Temporal TLS mount for mgmt/pipeline-backend-init ([#1308](https://github.com/instill-ai/instill-core/issues/1308)) ([e2dda76](https://github.com/instill-ai/instill-core/commit/e2dda762142f39e9086d4d5f327cbd1aeeefce0d))
* **helm:** bump chart with RC tag ([#1326](https://github.com/instill-ai/instill-core/issues/1326)) ([886f74f](https://github.com/instill-ai/instill-core/commit/886f74fcd950663f120e87f4e3fa3dca033009f3))
* **helm:** remove the unused DB version config ([#1319](https://github.com/instill-ai/instill-core/issues/1319)) ([8392fc2](https://github.com/instill-ai/instill-core/commit/8392fc2e6e01e189622a2a723079d5bbea62284b))
* **main:** release v0.54.0 ([4fc9cee](https://github.com/instill-ai/instill-core/commit/4fc9ceefc246b0560f1544611e16da435b204ecf))

## [0.1.64](https://github.com/instill-ai/instill-core/compare/helm-chart-v0.1.63...helm-chart-v0.1.64) (2025-07-17)


### Features

* **observe:** update observablity stack ([#1250](https://github.com/instill-ai/instill-core/issues/1250)) ([d3595c4](https://github.com/instill-ai/instill-core/commit/d3595c4de39b0182de1d812bd4b82db1ec639aa7))


### Miscellaneous

* **charts:** update README for new domain instill-ai.com ([#1270](https://github.com/instill-ai/instill-core/issues/1270)) ([f5f58eb](https://github.com/instill-ai/instill-core/commit/f5f58eb2f4ba53b2831f56ca20b138d08892b0dc))
* **env:** bump OpenFGA version ([#1278](https://github.com/instill-ai/instill-core/issues/1278)) ([167a7f0](https://github.com/instill-ai/instill-core/commit/167a7f08cbc115ea3a8e6f0f955cb4a4cf1c88ea))
* **helm,compose:** add `instillCoreHost` environment variable to artifact-backend ([#1275](https://github.com/instill-ai/instill-core/issues/1275)) ([60978f3](https://github.com/instill-ai/instill-core/commit/60978f3ef399aa7df9caa596321c2fb2b63cc3af))
* **helm:** add insecureSkipVerify setting for Temporal ([#1281](https://github.com/instill-ai/instill-core/issues/1281)) ([5b83224](https://github.com/instill-ai/instill-core/commit/5b8322435d571df8c955a3b9c9ba0534fc9b7ce3))
* **helm:** update outdated Temporal config ([#1279](https://github.com/instill-ai/instill-core/issues/1279)) ([9eb297c](https://github.com/instill-ai/instill-core/commit/9eb297ce940b6487a8c2d421e89471eaf99c16d2))
* **hpa:** update hpa for all the backend-services ([#1269](https://github.com/instill-ai/instill-core/issues/1269)) ([0c679f1](https://github.com/instill-ai/instill-core/commit/0c679f13d12c9b8aae4a41529e06e4bf5b3e3ebf))
