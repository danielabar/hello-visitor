# Feature Tests

This document explains the feature testing setup in the project, along with links to documentation and debugging instructions.

## Stack

Feature tests use several tools for behavior-driven development and browser-based testing. Here are the libraries we use and their documentation for reference:

- **Cucumber**: For defining and running high-level feature scenarios.
  - [Cucumber Documentation](https://cucumber.io/docs/cucumber/)
  - [Cucumber Expressions](https://github.com/cucumber/cucumber-expressions#readme)
  - [Cucumber-Rails](https://github.com/cucumber/cucumber-rails)
- **Capybara**: Provides a DSL to interact with web pages during tests.
  - [Capybara GitHub Repository](https://github.com/teamcapybara/capybara)
  - [Capybara API Documentation](https://rubydoc.info/github/teamcapybara/capybara/master)
  - [Capybara Node Actions](https://rubydoc.info/github/teamcapybara/capybara/master/Capybara/Node/Actions)
  - [Cuprite](https://github.com/rubycdp/cuprite) - Headless Chrome/Chromium driver for Capybara
  - [Ferrum](https://github.com/rubycdp/ferrum#index) - Used by Cuprite,  high-level API to the browser by CDP protocol.

## Running

```bash
bin/cucumber
```

Runs all tests in `features/*.feature`.

## Configuration

See `features/support/*.rb`

## Debugging

Debugging is an essential part of resolving test issues. Two primary techniques are available for debugging feature tests: disabling headless mode and using an inspector.

### Technique 1: Disabling Headless Mode

To run tests with a visible browser:
1. Set the `NOT_HEADLESS` environment variable:
   ```bash
   NOT_HEADLESS=1 bin/cucumber
   ```
2. Insert a `debugger` statement in your step definitions. This pauses test execution, allowing you to inspect the state interactively in the visible browser.

### Technique 2: Using an Inspector

Alternatively, you can enable an inspector to debug specific test parts directly in the browser:
1. Set the `INSPECTOR` environment variable:
   ```bash
   INSPECTOR=1 bin/cucumber
   ```
2. Use the following line in your step definitions to pause execution and open the browser's developer tools:
   ```ruby
   page.driver.debug(binding)
   ```
This approach doesn’t require headless mode to be disabled and offers an interactive debugging experience through browser tools.

## Notes

- The feature testing setup was initialized with the command:
  ```bash
  bin/rails generate cucumber:install
  ```
  *(This is a note for context, not an instruction to repeat.)*
