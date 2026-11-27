# Changelog

## [5.0.0](https://github.com/SchweizerischeBundesbahnen/data-scanner-flutter/compare/4.4.2...5.0.0) (2026-11-27)


### ⚠ BREAKING CHANGES

* add SPM support from community port

### Features

* add SPM support from community port ([d365aca](https://github.com/SchweizerischeBundesbahnen/data-scanner-flutter/commit/d365aca2b2c72f12548d113be5ea35c46a9693ef))


### Bug Fixes

* **android:** avoid oversized NV21 buffer and unused plane copy per frame ([#87](https://github.com/SchweizerischeBundesbahnen/data-scanner-flutter/issues/87)) ([322224a](https://github.com/SchweizerischeBundesbahnen/data-scanner-flutter/commit/322224ad5b4af4947e59c44f57fd7209e85670f4)), closes [#75](https://github.com/SchweizerischeBundesbahnen/data-scanner-flutter/issues/75)
* rebuilt data scanner re applies updated configuration ([fba66f1](https://github.com/SchweizerischeBundesbahnen/data-scanner-flutter/commit/fba66f125d81cbbc70e11a41e5b094dd75edfcc5))
* unsubscribe DataScanner from the route observer ([#86](https://github.com/SchweizerischeBundesbahnen/data-scanner-flutter/issues/86)) ([52c7afa](https://github.com/SchweizerischeBundesbahnen/data-scanner-flutter/commit/52c7afa464b50b856264bdfdee2aa5baee50d813)), closes [#85](https://github.com/SchweizerischeBundesbahnen/data-scanner-flutter/issues/85)

## [4.4.2](https://github.com/SchweizerischeBundesbahnen/data-scanner-flutter/compare/4.4.1...4.4.2) (2025-11-26)


### Bug Fixes

* bump minimum supported Flutter SDK version to 3.35.x for Camera ([fe97685](https://github.com/SchweizerischeBundesbahnen/data-scanner-flutter/commit/fe97685f601bc1d0d14c80881e6c752cd8eed53d))
* convert images to nv21 in dart code to prevent issue in mlKit ([7f1f4eb](https://github.com/SchweizerischeBundesbahnen/data-scanner-flutter/commit/7f1f4eb81b0bf2206387f884fe275b07a28f535f))

## [4.4.1](https://github.com/SchweizerischeBundesbahnen/data-scanner-flutter/compare/4.4.0...4.4.1) (2024-12-18)


### Bug Fixes

* pin mlkit versions to fix crash in scanning ([#7](https://github.com/SchweizerischeBundesbahnen/data-scanner-flutter/issues/7)) ([8cd946d](https://github.com/SchweizerischeBundesbahnen/data-scanner-flutter/commit/8cd946d10d83510ae21e38623272e91cb9af2273))

## [4.4.0](https://github.com/SchweizerischeBundesbahnen/data-scanner-flutter/compare/v4.3.0...4.4.0) (2024-12-18)


### Features

* add initial structure for open source repo ([5abd7fc](https://github.com/SchweizerischeBundesbahnen/data-scanner-flutter/commit/5abd7fcc5165347ad4f0b94235628b23c44b4aa9))
