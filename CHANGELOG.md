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
### new methode
- force_remove it ignores RecipientNotInList

[0.7.0]: https://github.com/freeletics/optivo_api/compare/v0.6.0...v0.7.0
[0.7.1]: https://github.com/freeletics/optivo_api/compare/v0.7.0...v0.7.1
[0.7.2]: https://github.com/freeletics/optivo_api/compare/v0.7.1...v0.7.2
[0.7.3]: https://github.com/freeletics/optivo_api/compare/v0.7.2...v0.7.3
[0.7.4]: https://github.com/freeletics/optivo_api/compare/v0.7.3...v0.7.4
[0.7.4]: https://github.com/freeletics/optivo_api/compare/v0.7.4...v0.7.5
