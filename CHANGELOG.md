# Changelog

## [0.36.0-beta](https://github.com/instill-ai/instill-core/compare/v0.35.0-beta...v0.36.0-beta) (2024-07-16)


### Bug Fixes

* **core:** make value in yaml compatible with strict parser ([#1037](https://github.com/instill-ai/instill-core/issues/1037)) ([ad6594a](https://github.com/instill-ai/instill-core/commit/ad6594a4f5c1501f7e8bad5d46c9b44f1f803c7c))


### Miscellaneous Chores

* release v0.36.0-beta ([55d63a4](https://github.com/instill-ai/instill-core/commit/55d63a4c525a1544f6b9c4875c68a37881c77854))

## [0.35.0-beta](https://github.com/instill-ai/instill-core/compare/v0.34.0-beta...v0.35.0-beta) (2024-07-02)


### Features

* **helm:** support registry image deletion and garbage-collect ([#1029](https://github.com/instill-ai/instill-core/issues/1029)) ([04b8c86](https://github.com/instill-ai/instill-core/commit/04b8c861ceb750fe70382b1384527a6191ce0b80))

## [0.34.0-beta](https://github.com/instill-ai/instill-core/compare/v0.33.0-beta...v0.34.0-beta) (2024-06-19)


### Miscellaneous Chores

* release v0.34.0-beta ([bddd3b7](https://github.com/instill-ai/instill-core/commit/bddd3b79adbd6e3db7431229a410be6a301cc0a7))

## [0.33.0-beta](https://github.com/instill-ai/instill-core/compare/v0.32.0-beta...v0.33.0-beta) (2024-06-06)


### Features

* **artifact:** add minio and milvus for artifact storage ([#999](https://github.com/instill-ai/instill-core/issues/999)) ([14713d9](https://github.com/instill-ai/instill-core/commit/14713d924a15828caf7cbfbe567f43c9edd0f71c))
* **mgmt:** run migration only on main cluster in mgmt-backend ([#1007](https://github.com/instill-ai/instill-core/issues/1007)) ([26fedff](https://github.com/instill-ai/instill-core/commit/26fedff640814ad68eb353706c142fc8dd1e2b39))
* **ray:** update infra to accommodate containerized model serving ([#494](https://github.com/instill-ai/instill-core/issues/494)) ([8c4b3e1](https://github.com/instill-ai/instill-core/commit/8c4b3e1dc08bb93e9a7b008ff41cc620cde96a37))


### Bug Fixes

* **artifact:** modify healthy check request ([#1003](https://github.com/instill-ai/instill-core/issues/1003)) ([c4225aa](https://github.com/instill-ai/instill-core/commit/c4225aac0b8f3236474b926ec4f13ef46318f9ba))


### Miscellaneous Chores

* release v0.33.0-beta ([1cc19b9](https://github.com/instill-ai/instill-core/commit/1cc19b92ce936983cdd800fd7e3e7b23badb6038))

## [0.32.0-beta](https://github.com/instill-ai/instill-core/compare/v0.31.0-beta...v0.32.0-beta) (2024-05-16)


### Miscellaneous Chores

* release v0.32.0-beta ([f0d42fe](https://github.com/instill-ai/instill-core/commit/f0d42fed0429c0e53c4c559207be5386aaa9368b))

## [0.31.0-beta](https://github.com/instill-ai/instill-core/compare/v0.30.0-beta...v0.31.0-beta) (2024-05-07)


### Miscellaneous Chores

* release v0.31.0-beta ([9df345b](https://github.com/instill-ai/instill-core/commit/9df345b6969005bcfa0578c31974ddaf7ddda3cd))

## [0.30.0-beta](https://github.com/instill-ai/instill-core/compare/v0.29.0-beta...v0.30.0-beta) (2024-04-25)


### Miscellaneous Chores

* release v0.30.0-beta ([0840c1a](https://github.com/instill-ai/instill-core/commit/0840c1a5dee339e93635fe22ebe989c5cb7aad8e))

## [0.29.0-beta](https://github.com/instill-ai/instill-core/compare/v0.28.0-beta...v0.29.0-beta) (2024-04-12)


### Features

* **artifact:** include artifact-backend ([#464](https://github.com/instill-ai/instill-core/issues/464)) ([dc0eea0](https://github.com/instill-ai/instill-core/commit/dc0eea0c0fc86513a18cc88f46c2bd3d930d9d60))

## [0.28.0-beta](https://github.com/instill-ai/instill-core/compare/v0.27.0-beta...v0.28.0-beta) (2024-04-09)


### Miscellaneous Chores

* release v0.28.0-beta ([8083a44](https://github.com/instill-ai/instill-core/commit/8083a4488bc63169b115e8ff6553a61d26da02a2))

## [0.27.0-beta](https://github.com/instill-ai/instill-core/compare/v0.26.1-beta...v0.27.0-beta) (2024-04-02)


### Features

* **helm,docker-compose:** add registry service ([#435](https://github.com/instill-ai/instill-core/issues/435)) ([8f56582](https://github.com/instill-ai/instill-core/commit/8f565827856c91ea5efca33562cd4445a4203c1e))
* **helm:** add configuration for read-replica database ([#455](https://github.com/instill-ai/instill-core/issues/455)) ([ba80559](https://github.com/instill-ai/instill-core/commit/ba805598e1b0fbc9a835ec1103196617554a06c2))
* **model:** support new models ([#457](https://github.com/instill-ai/instill-core/issues/457)) ([7e311d5](https://github.com/instill-ai/instill-core/commit/7e311d5499f2476bacd902ea037470f1d1e3587d))


### Bug Fixes

* **cicd:** fix uploading console tests artifact issue ([#463](https://github.com/instill-ai/instill-core/issues/463)) ([78b001d](https://github.com/instill-ai/instill-core/commit/78b001df4d39146099c03b3d9163bc73c1751333))


### Miscellaneous Chores

* release v0.27.0-beta ([c0c331a](https://github.com/instill-ai/instill-core/commit/c0c331ac34699b64a0dd34a3d27a2b560d6c7029))

## [0.26.1-beta](https://github.com/instill-ai/instill-core/compare/v0.26.0-beta...v0.26.1-beta) (2024-03-20)


### Miscellaneous Chores

* release v0.26.1-beta ([1a7506c](https://github.com/instill-ai/instill-core/commit/1a7506cf1fa14297cba957903c16c149a1ec89ad))

## [0.26.0-beta](https://github.com/instill-ai/instill-core/compare/v0.25.0-beta...v0.26.0-beta) (2024-03-13)


### Features

* **model:** support Llava 13b ([#442](https://github.com/instill-ai/instill-core/issues/442)) ([39bbf8c](https://github.com/instill-ai/instill-core/commit/39bbf8c21d055c791e21cccaa9ccdd14243ca094))


### Bug Fixes

* **docker-compose:** add `INSTILL_CORE_HOST` back for Console to connect to the backend properly ([#441](https://github.com/instill-ai/instill-core/issues/441)) ([601f963](https://github.com/instill-ai/instill-core/commit/601f96309bdd76e11faf6508874e2c220ccca8d8))

## [0.25.0-beta](https://github.com/instill-ai/instill-core/compare/v0.24.0-beta...v0.25.0-beta) (2024-03-02)


### Miscellaneous Chores

* release v0.25.0-beta ([beecc6d](https://github.com/instill-ai/instill-core/commit/beecc6d5e0df21372f874351836fc6adb62b5850))

## [0.24.0-beta](https://github.com/instill-ai/instill-core/compare/v0.23.0-beta...v0.24.0-beta) (2024-02-29)


### Miscellaneous Chores

* release v0.24.0-beta ([6abf163](https://github.com/instill-ai/instill-core/commit/6abf163216d8adf4d565f5571e0297d2516c794f))

## [0.23.0-beta](https://github.com/instill-ai/vdp/compare/v0.22.1-beta...v0.23.0-beta) (2024-02-16)


### Miscellaneous Chores

* release v0.23.0-beta ([5c93c12](https://github.com/instill-ai/vdp/commit/5c93c12badc7a156ec7d284297bd8540944dd6b3))

## [0.22.1-beta](https://github.com/instill-ai/vdp/compare/v0.22.0-beta...v0.22.1-beta) (2024-02-06)


### Miscellaneous Chores

* release v0.22.1-beta ([463338a](https://github.com/instill-ai/vdp/commit/463338a61c2ffa35db4d490656d1409a336a43e2))

## [0.22.0-beta](https://github.com/instill-ai/vdp/compare/v0.21.0-beta...v0.22.0-beta) (2024-01-30)


### Miscellaneous Chores

* release v0.22.0-beta ([d5299cc](https://github.com/instill-ai/vdp/commit/d5299ccfee5d4d052e487f28e4b3d184695ff100))

## [0.21.0-beta](https://github.com/instill-ai/vdp/compare/v0.20.0-beta...v0.21.0-beta) (2024-01-15)


### Miscellaneous Chores

* release v0.21.0-beta ([4a28fb7](https://github.com/instill-ai/vdp/commit/4a28fb7aa27daf5dbad8ad8f6a2f1985a28c4a42))

## [0.20.0-beta](https://github.com/instill-ai/vdp/compare/v0.19.1-beta...v0.20.0-beta) (2024-01-02)


### Miscellaneous Chores

* release v0.20.0-beta ([1ba40b2](https://github.com/instill-ai/vdp/commit/1ba40b24c5a56042e25a9bfa4e0fd6c9c72b4a14))

## [0.19.1-beta](https://github.com/instill-ai/vdp/compare/v0.19.0-beta...v0.19.1-beta) (2023-12-20)


### Miscellaneous Chores

* release v0.19.1-beta ([cc4998c](https://github.com/instill-ai/vdp/commit/cc4998cea6185b080af34ba2f8f856acaab15d40))

## [0.19.0-beta](https://github.com/instill-ai/vdp/compare/v0.18.0-alpha...v0.19.0-beta) (2023-12-15)


### Miscellaneous Chores

* release v0.19.0-beta ([56ae74a](https://github.com/instill-ai/vdp/commit/56ae74a98317e3f298dee30f6077bc3e7520dbef))

## [0.18.0-alpha](https://github.com/instill-ai/vdp/compare/v0.17.1-alpha...v0.18.0-alpha) (2023-11-28)


### Miscellaneous Chores

* release v0.18.0-alpha ([c7674f7](https://github.com/instill-ai/vdp/commit/c7674f74a4c0945c384ebc1e7ae0def611be5b8c))

## [0.17.1-alpha](https://github.com/instill-ai/vdp/compare/v0.17.0-alpha...v0.17.1-alpha) (2023-11-13)


### Miscellaneous Chores

* release v0.17.1-alpha ([46cf9af](https://github.com/instill-ai/vdp/commit/46cf9afc3028a5aa46772af3df030d9a8c872cdc))

## [0.17.0-alpha](https://github.com/instill-ai/vdp/compare/v0.16.0-alpha...v0.17.0-alpha) (2023-10-27)


### Miscellaneous Chores

* **release:** release v0.17.0-alpha ([f1eb091](https://github.com/instill-ai/vdp/commit/f1eb09120b9bef728da0d9559f33c32d895d0ff1))

## [0.16.0-alpha](https://github.com/instill-ai/vdp/compare/v0.15.0-alpha...v0.16.0-alpha) (2023-10-13)


### Miscellaneous Chores

* **release:** release v0.16.0-alpha ([6355d33](https://github.com/instill-ai/vdp/commit/6355d335477898acea0e40b9fa32131179092531))

## [0.15.0-alpha](https://github.com/instill-ai/vdp/compare/v0.14.0-alpha...v0.15.0-alpha) (2023-09-30)


### Bug Fixes

* **makefile:** fix `helm-integration-test-latest` bug ([#361](https://github.com/instill-ai/vdp/issues/361)) ([1db4632](https://github.com/instill-ai/vdp/commit/1db4632ff2548db58ead50ffce5f96f4eb8d2ea3))


### Miscellaneous Chores

* **release:** release v0.15.0-alpha ([19fe7f8](https://github.com/instill-ai/vdp/commit/19fe7f8f1c4a1a66d22c9584c2f859119de9c08f))

## [0.14.0-alpha](https://github.com/instill-ai/vdp/compare/v0.13.0-alpha...v0.14.0-alpha) (2023-09-13)


### Miscellaneous Chores

* **release:** release v0.14.0-alpha ([6a560ed](https://github.com/instill-ai/vdp/commit/6a560edb5a48b22c97437bfe08450e48fa8cc428))

## [0.13.0-alpha](https://github.com/instill-ai/vdp/compare/v0.12.0-alpha...v0.13.0-alpha) (2023-08-03)


### Miscellaneous Chores

* **release:** release v0.13.0-alpha ([7476977](https://github.com/instill-ai/vdp/commit/7476977c1f2537a22e5d1a29c4560a1ee6e77012))

## [0.12.0-alpha](https://github.com/instill-ai/vdp/compare/v0.11.0-alpha...v0.12.0-alpha) (2023-07-20)


### Miscellaneous Chores

* **release:** release v0.12.0-alpha ([129e22f](https://github.com/instill-ai/vdp/commit/129e22f8b59037b25e0fe6bbdd3fc8d27a4689ea))

## [0.11.0-alpha](https://github.com/instill-ai/vdp/compare/v0.10.2-alpha...v0.11.0-alpha) (2023-07-11)


### Miscellaneous Chores

* **release:** release v0.11.0-alpha ([fae0e4e](https://github.com/instill-ai/vdp/commit/fae0e4ebc860dacb65f63e5afbff788b6d502752))

## [0.10.2-alpha](https://github.com/instill-ai/vdp/compare/v0.10.1-alpha...v0.10.2-alpha) (2023-06-21)


### Miscellaneous Chores

* **release:** release 0.10.2-alpha ([43368f8](https://github.com/instill-ai/vdp/commit/43368f8031b863d6db123d32c6933704e288d628))

## [0.10.1-alpha](https://github.com/instill-ai/vdp/compare/v0.10.0-alpha...v0.10.1-alpha) (2023-06-11)


### Miscellaneous Chores

* release v0.10.1-alpha ([a6ccf48](https://github.com/instill-ai/vdp/commit/a6ccf489ce46697e3c680ab0f7069418d132084e))

## [0.10.0-alpha](https://github.com/instill-ai/vdp/compare/v0.9.3-alpha...v0.10.0-alpha) (2023-06-02)


### Miscellaneous Chores

* **release:** release 0.10.0-alpha ([3a84090](https://github.com/instill-ai/vdp/commit/3a84090a951213f872c9b00793e493b6125e7af4))

## [0.9.3-alpha](https://github.com/instill-ai/vdp/compare/v0.9.2-alpha...v0.9.3-alpha) (2023-05-12)


### Miscellaneous Chores

* **release:** release 0.9.3-alpha ([6b85298](https://github.com/instill-ai/vdp/commit/6b852989304da3310fc46bf3dc3743732bd7ef1f))

## [0.9.2-alpha](https://github.com/instill-ai/vdp/compare/v0.9.1-alpha...v0.9.2-alpha) (2023-04-30)


### Miscellaneous Chores

* release v0.9.2-alpha ([471c189](https://github.com/instill-ai/vdp/commit/471c18910a0cfca9c228fe083338f2d39bdd08da))

## [0.9.1-alpha](https://github.com/instill-ai/vdp/compare/v0.9.0-alpha...v0.9.1-alpha) (2023-04-15)


### Miscellaneous Chores

* **release:** release v0.9.1-alpha ([a13d341](https://github.com/instill-ai/vdp/commit/a13d341e3bb995e145ff6f3a060aabe927e527bb))

## [0.9.0-alpha](https://github.com/instill-ai/vdp/compare/v0.8.1-alpha...v0.9.0-alpha) (2023-04-09)


### Miscellaneous Chores

* **release:** release v0.9.0-alpha ([0670c0a](https://github.com/instill-ai/vdp/commit/0670c0a5f8f0ad6ebaea656c8cb6b56a3295fe83))

## [0.8.1-alpha](https://github.com/instill-ai/vdp/compare/v0.8.0-alpha...v0.8.1-alpha) (2023-03-26)


### Miscellaneous Chores

* release v0.8.1-alpha ([87084c9](https://github.com/instill-ai/vdp/commit/87084c9a1b0661e3c588977f9f65039e62e5e2d1))

## [0.8.0-alpha](https://github.com/instill-ai/vdp/compare/v0.7.0-alpha...v0.8.0-alpha) (2023-03-01)


### Miscellaneous Chores

* release v0.8.0-alpha ([4e5cb3d](https://github.com/instill-ai/vdp/commit/4e5cb3db99e4e173e5068b087eb49eca55f32889))

## [0.7.0-alpha](https://github.com/instill-ai/vdp/compare/v0.6.0-alpha...v0.7.0-alpha) (2023-02-28)


### Miscellaneous Chores

* release v0.7.0-alpha ([df4d57a](https://github.com/instill-ai/vdp/commit/df4d57acdcd31fb9e67dd597860d7ded7ba1a19c))

## [0.6.0-alpha](https://github.com/instill-ai/vdp/compare/v0.5.0-alpha...v0.6.0-alpha) (2023-02-23)


### Features

* add helm charts ([#155](https://github.com/instill-ai/vdp/issues/155)) ([eaa78cb](https://github.com/instill-ai/vdp/commit/eaa78cbedbceb5237d051f5a31c577cafe603cd5))
* update console env ([#201](https://github.com/instill-ai/vdp/issues/201)) ([e832b74](https://github.com/instill-ai/vdp/commit/e832b74c654f612b7df64872744fe9abde42bf67))


### Bug Fixes

* fix console e2e config ([#203](https://github.com/instill-ai/vdp/issues/203)) ([3d7038f](https://github.com/instill-ai/vdp/commit/3d7038fd018b72d0823f55fa66fe1f0a4f393fa5))

## [0.5.0-alpha](https://github.com/instill-ai/vdp/compare/v0.4.1-alpha...v0.5.0-alpha) (2023-02-10)


### Miscellaneous Chores

* release 0.5.0-alpha ([4cf3593](https://github.com/instill-ai/vdp/commit/4cf3593f39cab2c29b135a8e7fb954c15fe2901e))

## [0.4.1-alpha](https://github.com/instill-ai/vdp/compare/v0.4.0-alpha...v0.4.1-alpha) (2023-01-21)


### Miscellaneous Chores

* release v0.4.1-alpha ([1281217](https://github.com/instill-ai/vdp/commit/1281217eb899e96abee48ddf37295f66f9ab9fc8))

## [0.4.0-alpha](https://github.com/instill-ai/vdp/compare/v0.3.0-alpha...v0.4.0-alpha) (2023-01-15)


### Features

* enable h2c for api-gateway to handle both http and https ([#183](https://github.com/instill-ai/vdp/issues/183)) ([c4115f6](https://github.com/instill-ai/vdp/commit/c4115f6b722738d581830490c29647654777fed8))

## [0.3.0-alpha](https://github.com/instill-ai/vdp/compare/v0.2.6-alpha...v0.3.0-alpha) (2022-12-24)


### Features

* add console e2e test into vdp ([#148](https://github.com/instill-ai/vdp/issues/148)) ([a779a11](https://github.com/instill-ai/vdp/commit/a779a11d42259923e09220df25d8006a7353026e))


### Bug Fixes

* error triton environment when deploying HuggingFace models ([#150](https://github.com/instill-ai/vdp/issues/150)) ([b2fda36](https://github.com/instill-ai/vdp/commit/b2fda36e687ed347e39d6c4e6f4448a289ca6acf))

* fix docker-compose  ([#174](https://github.com/instill-ai/vdp/issues/174)) ([e40d607](https://github.com/instill-ai/vdp/commit/e40d60789e3a93839a1ece01dea30144a0e667f9))
* fix: fix typo in makefile ([#172](https://github.com/instill-ai/vdp/issues/172)) ([c861afd](https://github.com/instill-ai/vdp/commit/c861afd991c368db15195f26dec658691cefda8c))

## [0.2.6-alpha](https://github.com/instill-ai/vdp/compare/v0.2.5-alpha...v0.2.6-alpha) (2022-09-20)


### Bug Fixes

* update examples to be compatible with the latest protocol ([36a847b](https://github.com/instill-ai/vdp/commit/36a847b57ab1725ccd22df53eb0e203e729841d8))


### Miscellaneous Chores

* release v0.2.6-alpha ([b291862](https://github.com/instill-ai/vdp/commit/b291862532d452733fd21e5942aaa82af5c14839))

## [0.2.5-alpha](https://github.com/instill-ai/vdp/compare/v0.2.4-alpha...v0.2.5-alpha) (2022-08-18)


### Miscellaneous Chores

* release 0.2.5-alpha ([0ebcd04](https://github.com/instill-ai/vdp/commit/0ebcd04c0f55689bda357e1adf33c3cfa5265d7b))

## [0.2.4-alpha](https://github.com/instill-ai/vdp/compare/v0.2.3-alpha...v0.2.4-alpha) (2022-08-01)


### Miscellaneous Chores

* release 0.2.4-alpha ([955cff3](https://github.com/instill-ai/vdp/commit/955cff388cafb3e3457fa7f7f9bdbdb425bc1306))

## [0.2.3-alpha](https://github.com/instill-ai/vdp/compare/v0.2.2-alpha...v0.2.3-alpha) (2022-07-29)


### Miscellaneous Chores

* release v0.2.3-alpha ([ca6486f](https://github.com/instill-ai/vdp/commit/ca6486f7295c68267f65a6c9430e626aa5b80118))

## [0.2.2-alpha](https://github.com/instill-ai/vdp/compare/v0.2.1-alpha...v0.2.2-alpha) (2022-07-20)


### Miscellaneous Chores

* release v0.2.2-alpha ([2459ab1](https://github.com/instill-ai/vdp/commit/2459ab1a0274450ed9ae65663dceb4a4088d141e))

## [0.2.1-alpha](https://github.com/instill-ai/vdp/compare/v0.2.0-alpha...v0.2.1-alpha) (2022-07-12)


### Miscellaneous Chores

* release 0.2.1-alpha ([d098333](https://github.com/instill-ai/vdp/commit/d0983333434fa10f5b95e9187092a0582a98e2aa))

## [0.2.0-alpha](https://github.com/instill-ai/vdp/compare/v0.1.6-alpha...v0.2.0-alpha) (2022-07-08)


### Features

* add console ([3151126](https://github.com/instill-ai/vdp/commit/315112667bba2e1ff53354ce98cf4a9254973566))


### Bug Fixes

* fix connector-backend-worker in docker-compose-dev ([c5d7260](https://github.com/instill-ai/vdp/commit/c5d7260e4942625c8c4f33086d0c19af3c3c873a))
* fix OpenAPI swagger service ([#104](https://github.com/instill-ai/vdp/issues/104)) ([2e3fd90](https://github.com/instill-ai/vdp/commit/2e3fd90e11cc54944bfed0d136f64587f3f698fa))
* fix temporal dynamicconfig ([57edcde](https://github.com/instill-ai/vdp/commit/57edcde477e56c4cc9a275a4b847f3dfff58ec32))

### [0.1.6-alpha](https://github.com/instill-ai/vdp/compare/v0.1.5-alpha...v0.1.6-alpha) (2022-04-03)


### Miscellaneous Chores

* release 0.1.6-alpha ([66e4988](https://github.com/instill-ai/vdp/commit/66e498857a67af7343096512fbf73fbc741e7611))

### [0.1.5-alpha](https://github.com/instill-ai/vdp/compare/v0.1.4-alpha...v0.1.5-alpha) (2022-03-22)


### Miscellaneous Chores

* release 0.1.5-alpha ([36da44e](https://github.com/instill-ai/vdp/commit/36da44ebd27bb8b7aa6f1fdcf39f432293501275))

### [0.1.4-alpha](https://github.com/instill-ai/vdp/compare/v0.1.3-alpha...v0.1.4-alpha) (2022-03-22)


### Miscellaneous Chores

* release 0.1.4-alpha ([0b0e649](https://github.com/instill-ai/vdp/commit/0b0e64915491aac3b3a2a6274da30bdd1a7c940d))

### [0.1.3-alpha](https://github.com/instill-ai/vdp/compare/v0.1.2-alpha...v0.1.3-alpha) (2022-02-24)


### Bug Fixes

* some typos in examples-go ([#80](https://github.com/instill-ai/vdp/issues/80)) ([d81f564](https://github.com/instill-ai/vdp/commit/d81f5649265c2deb1ff9b08fd31b2ad779450922))
* typos in examples-go ([#77](https://github.com/instill-ai/vdp/issues/77)) ([cb94c9f](https://github.com/instill-ai/vdp/commit/cb94c9fbcf3bbfa98a2f691ab50d33bfb5afd7c0))

### [0.1.2-alpha](https://github.com/instill-ai/vdp/compare/v0.1.1-alpha...v0.1.2-alpha) (2022-02-21)


### Bug Fixes

* add name in update model api ([#41](https://github.com/instill-ai/vdp/issues/41)) ([35b7e31](https://github.com/instill-ai/vdp/commit/35b7e31f8771eccf16bcd7cc36785138540c869d))
* **docker-compose:** change correct dependency for temporal ([#60](https://github.com/instill-ai/vdp/issues/60)) ([eb98049](https://github.com/instill-ai/vdp/commit/eb98049b21fe6d6e4c037234dbc6cde9cf32b325))
* update model backend without specify version when creating model ([#63](https://github.com/instill-ai/vdp/issues/63)) ([f4cf161](https://github.com/instill-ai/vdp/commit/f4cf161fa789573985b47e465fc9a30c6da9ec6c))
* wrong type in sample model prediction ([#39](https://github.com/instill-ai/vdp/issues/39)) ([523d5f8](https://github.com/instill-ai/vdp/commit/523d5f8ea1d8b00799ceb5aef183ae727069726c))

### [0.1.1-alpha](https://github.com/instill-ai/vdp/compare/v0.1.0-alpha...v0.1.1-alpha) (2022-02-13)


### Miscellaneous Chores

* release 0.1.1-alpha ([932e3ee](https://github.com/instill-ai/vdp/commit/932e3eed14d6bd672ae0f00938cc0afd7992163c))

## [0.1.0-alpha](https://github.com/instill-ai/visual-data-preparation/compare/v0.0.0-alpha...v0.1.0-alpha) (2022-02-11)


### Features

* add provisioned `visual-data-pipeline` from docker-compose ([0ec790b](https://github.com/instill-ai/visual-data-preparation/commit/0ec790b4d99aae5c99544a571b3f349f51d2ee75))
* initial commit ([2916d75](https://github.com/instill-ai/visual-data-preparation/commit/2916d757f49bf922b2582a5a598086fa79f58162))
* refactor the name to `visual data preparation` and add `model-backend` into docker-compose ([#7](https://github.com/instill-ai/visual-data-preparation/issues/7)) ([d24c0ef](https://github.com/instill-ai/visual-data-preparation/commit/d24c0efa4579d1dab122d8db3c18e976504f9399))
* refactor to adopt koanf configuration management ([51eba89](https://github.com/instill-ai/visual-data-preparation/commit/51eba893746dceb2a0f57ecb6069f72a8f74a2b3))


### Bug Fixes

* fix dependency ([d418871](https://github.com/instill-ai/visual-data-preparation/commit/d418871d04fd20dff30da8b492b740f32d7f6fcd))
* fix wrong package ([740cda0](https://github.com/instill-ai/visual-data-preparation/commit/740cda07363488c66a27563ea91d6fbe935a1f57))
* remove unused file ([78e5d98](https://github.com/instill-ai/visual-data-preparation/commit/78e5d98c44da65ec37e73a36cac2c745a4e4bc97))
* use public dockerhub as our image repository ([#4](https://github.com/instill-ai/visual-data-preparation/issues/4)) ([f8ba1b8](https://github.com/instill-ai/visual-data-preparation/commit/f8ba1b8f260f091f49dd72936e46087c68f6b42a))
* use public zapadapter ([2bc8c6d](https://github.com/instill-ai/visual-data-preparation/commit/2bc8c6dda4849c013b6b830c36cb0cebb338239d))
