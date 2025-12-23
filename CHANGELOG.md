# Changelog

## [3.1.0](https://github.com/CloudNationHQ/terraform-azure-dcr/compare/v3.0.0...v3.1.0) (2025-12-23)


### Features

* **deps:** bump github.com/cloudnationhq/az-cn-go-validor in /tests ([#36](https://github.com/CloudNationHQ/terraform-azure-dcr/issues/36)) ([2b05c4d](https://github.com/CloudNationHQ/terraform-azure-dcr/commit/2b05c4d2ce42a620242e0df3824847350f385684))
* **deps:** bump github.com/ulikunitz/xz from 0.5.10 to 0.5.14 in /tests ([#39](https://github.com/CloudNationHQ/terraform-azure-dcr/issues/39)) ([b8ea65d](https://github.com/CloudNationHQ/terraform-azure-dcr/commit/b8ea65d04e37e52ad06074fcde60fb97ec938b39))
* **deps:** bump golang.org/x/crypto from 0.36.0 to 0.45.0 in /tests ([#34](https://github.com/CloudNationHQ/terraform-azure-dcr/issues/34)) ([6af7bbd](https://github.com/CloudNationHQ/terraform-azure-dcr/commit/6af7bbd8cdb641dc156206e4db6f531cf1bf99b8))


### Bug Fixes

* make extension json property optional ([#37](https://github.com/CloudNationHQ/terraform-azure-dcr/issues/37)) ([09166c2](https://github.com/CloudNationHQ/terraform-azure-dcr/commit/09166c22ab3d1628f3c1a690cd5c3b6e0353f88c))

## [3.0.0](https://github.com/CloudNationHQ/terraform-azure-dcr/compare/v2.3.3...v3.0.0) (2025-11-05)


### ⚠ BREAKING CHANGES

* this change expects to change the existing data structure

### Features

* add type definitions and small refactor ([#31](https://github.com/CloudNationHQ/terraform-azure-dcr/issues/31)) ([669d23b](https://github.com/CloudNationHQ/terraform-azure-dcr/commit/669d23b1bea529034ca1bbf9d4730a8844b40188))

### Upgrade from v2.3.3 to v3.0.0:

- Update module reference to: `version = "~> 3.0"`
- The property and variable resource_group is renamed to resource_group_name

## [2.3.3](https://github.com/CloudNationHQ/terraform-azure-dcr/compare/v2.3.2...v2.3.3) (2025-09-22)


### Bug Fixes

* change logic for nontyped module ([#29](https://github.com/CloudNationHQ/terraform-azure-dcr/issues/29)) ([4ce13a1](https://github.com/CloudNationHQ/terraform-azure-dcr/commit/4ce13a162ff9af5e4b25ed28f7deabcd0512fad3))

## [2.3.2](https://github.com/CloudNationHQ/terraform-azure-dcr/compare/v2.3.1...v2.3.2) (2025-09-22)


### Bug Fixes

* default value for jsonencoded setting ([#27](https://github.com/CloudNationHQ/terraform-azure-dcr/issues/27)) ([db19d0b](https://github.com/CloudNationHQ/terraform-azure-dcr/commit/db19d0bf3484344d90c533becb7263c9f0748282))

## [2.3.1](https://github.com/CloudNationHQ/terraform-azure-dcr/compare/v2.3.0...v2.3.1) (2025-07-21)


### Bug Fixes

* single data_sources block  ([#23](https://github.com/CloudNationHQ/terraform-azure-dcr/issues/23)) ([6ddb29e](https://github.com/CloudNationHQ/terraform-azure-dcr/commit/6ddb29e89a0314fce959914110eaedbf053ad33e))

## [2.3.0](https://github.com/CloudNationHQ/terraform-azure-dcr/compare/v2.2.0...v2.3.0) (2025-01-20)


### Features

* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#14](https://github.com/CloudNationHQ/terraform-azure-dcr/issues/14)) ([e92aa81](https://github.com/CloudNationHQ/terraform-azure-dcr/commit/e92aa81624bb9510440f2eb71232464186a2f5eb))
* **deps:** bump golang.org/x/crypto from 0.29.0 to 0.31.0 in /tests ([#17](https://github.com/CloudNationHQ/terraform-azure-dcr/issues/17)) ([31275a1](https://github.com/CloudNationHQ/terraform-azure-dcr/commit/31275a12ac953c1069daf28984ce56b99b6eb904))
* **deps:** bump golang.org/x/net from 0.31.0 to 0.33.0 in /tests ([#18](https://github.com/CloudNationHQ/terraform-azure-dcr/issues/18)) ([9d08305](https://github.com/CloudNationHQ/terraform-azure-dcr/commit/9d083058068627704568ac3f8da22f743bac4555))
* remove temporary files when deployment tests fails ([#15](https://github.com/CloudNationHQ/terraform-azure-dcr/issues/15)) ([7003cf6](https://github.com/CloudNationHQ/terraform-azure-dcr/commit/7003cf6f972693cbfe0dd2b0919968d6a3990e26))

## [2.2.0](https://github.com/CloudNationHQ/terraform-azure-dcr/compare/v2.1.0...v2.2.0) (2024-11-11)


### Features

* enhance testing with sequential, parallel modes and flags for exceptions and skip-destroy ([#11](https://github.com/CloudNationHQ/terraform-azure-dcr/issues/11)) ([73f2345](https://github.com/CloudNationHQ/terraform-azure-dcr/commit/73f234500dbebbeb52228cebd92711baa39b5e1b))

## [2.1.0](https://github.com/CloudNationHQ/terraform-azure-dcr/compare/v2.0.0...v2.1.0) (2024-10-11)


### Features

* auto generated docs and refine makefile ([#9](https://github.com/CloudNationHQ/terraform-azure-dcr/issues/9)) ([14f8417](https://github.com/CloudNationHQ/terraform-azure-dcr/commit/14f84173ec6ac42b11ae83f0f2bc63a11c39997c))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#8](https://github.com/CloudNationHQ/terraform-azure-dcr/issues/8)) ([8d86ab7](https://github.com/CloudNationHQ/terraform-azure-dcr/commit/8d86ab773d488da39a6146375dbb345da267abc5))

## [2.0.0](https://github.com/CloudNationHQ/terraform-azure-dcr/compare/v1.0.1...v2.0.0) (2024-09-25)


### ⚠ BREAKING CHANGES

* Version 4 of the azurerm provider includes breaking changes.

### Features

* upgrade azurerm provider to v4 ([#6](https://github.com/CloudNationHQ/terraform-azure-dcr/issues/6)) ([385fc1b](https://github.com/CloudNationHQ/terraform-azure-dcr/commit/385fc1b2db97862a55adb6d399e2629e10839724))

### Upgrade from v1.0.1 to v2.0.0:

- Update module reference to: `version = "~> 2.0"`

## [1.0.1](https://github.com/CloudNationHQ/terraform-azure-dcr/compare/v1.0.0...v1.0.1) (2024-08-19)


### Bug Fixes

* fix module references ([#3](https://github.com/CloudNationHQ/terraform-azure-dcr/issues/3)) ([1b0044d](https://github.com/CloudNationHQ/terraform-azure-dcr/commit/1b0044d441952edd513ffb507b2772799fe937a2))

## 1.0.0 (2024-08-19)


### Features

* add initial data collection rule resources ([#1](https://github.com/CloudNationHQ/terraform-azure-dcr/issues/1)) ([ae7c419](https://github.com/CloudNationHQ/terraform-azure-dcr/commit/ae7c419376a1cc643e64560a261bc4602328d2d1))
