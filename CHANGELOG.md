# Optivo API Changelog

## [0.7.0] - 2015-12-3
### Changed
- setting for disable api calls
- update a recipient
- update_or_insert a recipient
- uniq cache key

## [0.7.1] - 2015-12-4
### Bugfixes
- safe response parsing for disabled calls

## [0.7.2] - 2015-12-4
### Bugfixes
- wrong call stack for OptivoApi::WebServices::Recipient#update_or_insert

## [0.7.3] - 2015-12-4
### Bugfixes
- Update README

## [0.7.4] - 2015-12-7
### Bugfixes
- new exception RecipientIsAlreadyOnThisList
- reduce api calls in method OptivoApi::WebServices#force_add

## [0.7.5] - 2015-12-8
### Bugfixes
- ignore RecipientIsAlreadyOnThisList for update_or_insert
### Added
- force_remove it ignores RecipientNotInList

## [0.7.6] - 2015-12-8
### Added
- add safe_add for not failing when user is already on the list

## [0.8.0] - 2016-01-19
### Changed
- changed recipient identifier from email to recipient_id

## [0.8.1] - 2016-01-19
### Bugfixes
- rubocop adjustments

## [0.8.2] - 2016-02-02
### Add
- Recipient#get


## [0.8.3] - 2016-02-02
### Add
- OptivoApi::WebServices::Unsubscribe

## [0.8.4] - 2016-03-12
### Add
- OptivoApi::WebServices::get throws exception RecipientNotInList when recipient not found

## [0.8.5] - 2016-03-15
### Bugfixes
- RecipientList#attribute_names work when api is disabled

## [0.9.0] - 2016-05-12
### Add
- possibility to use more mandaten in one app  

[0.7.0]: https://github.com/freeletics/optivo_api/compare/v0.6.0...v0.7.0
[0.7.1]: https://github.com/freeletics/optivo_api/compare/v0.7.0...v0.7.1
[0.7.2]: https://github.com/freeletics/optivo_api/compare/v0.7.1...v0.7.2
[0.7.3]: https://github.com/freeletics/optivo_api/compare/v0.7.2...v0.7.3
[0.7.4]: https://github.com/freeletics/optivo_api/compare/v0.7.3...v0.7.4
[0.7.5]: https://github.com/freeletics/optivo_api/compare/v0.7.4...v0.7.5
[0.7.6]: https://github.com/freeletics/optivo_api/compare/v0.7.5...v0.7.6
[0.8.0]: https://github.com/freeletics/optivo_api/compare/v0.7.6...v0.8.0
[0.8.1]: https://github.com/freeletics/optivo_api/compare/v0.8.0...v0.8.1
[0.8.2]: https://github.com/freeletics/optivo_api/compare/v0.8.1...v0.8.2
[0.8.3]: https://github.com/freeletics/optivo_api/compare/v0.8.2...v0.8.3
[0.8.4]: https://github.com/freeletics/optivo_api/compare/v0.8.3...v0.8.4
[0.8.5]: https://github.com/freeletics/optivo_api/compare/v0.8.4...v0.8.5
[0.9.0]: https://github.com/freeletics/optivo_api/compare/v0.8.5...v0.9.0
