# danger-francis
Plugin that allows reporting data to Francis.
Francis is Netguru internal tool for monitoring technical status of projects. This plugin reports data to our system.

## Installation

    $ gem 'danger-francis', git: 'https://github.com/netguru/danger-francis'

## Usage

    Methods and attributes from this plugin are available in
    your `Dangerfile` under the `francis` namespace.

#### Attributes

`reporting_url` - Url of the endpoint where report will be sent

`stack` - Stack of the project
Available values: android, ios, reactnative, flutter, ror, python

`ci_type` - CI type
Available values: bitrise, circleci

`project_id` - Valid Project id from Francis

`coverage` - Current code coverage in percentage

`lint_errors` - Number of lint errors

`lint_warnings` - Number of lint warnings

`build_time` - Build time in seconds [optional]
Automatically calculated when ci_type = bitrise

`dependencies_count` - Number of dependencies used in the project[optional]
Automatically calculated when stack = ios, flutter or android

`outdated_dependencies_count` - Number of outdated dependencies used in the project[optional]
Automatically calculated when stack = ios, flutter or android


### Methods

`send_report` - Sends the report to Francis

### Dangerfile
```ruby
#
#  Dangerfile
#
francis.reporting_url = "https://correct.address.com/api/francis"
francis.stack = "ios"
francis.ci_type = "bitrise"
francis.project_id = "uuid"
francis.coverage = 12
francis.lint_errors = 10
francis.lint_warnings = 21
francis.send_report # sends the report
```

#### Optional parameters inference
Plugin supports optional parameters, that in some conditions can be inferred automatically. However when provided no auto inference will happen.

##### Optional `build_time`
When `ci_type` is `bitrise` this property can be calculated automatically. No need of providing it.

##### Optional `dependencies_count` `outdated_dependencies_count`
When `stack` is `ios` those properties can be calculated automatically. No need of providing it.
Currently for iOS those values are calculated based on cocoapods and carthage reports.

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.

### Team
Owner & Maintainer: [@Siemian](https://github.com/Siemian/)
