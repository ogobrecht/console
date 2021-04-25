# Changelog

## v1.0-beta4 (2021-04-25)

- Add the ability to set specific PL/SQL units (packages, functions, procedures)
  to a different log level, if you want to monitor for example new code in all
  sessions (see [console.conf](package-console.md#procedure-conf))

## v1.0-beta3 (2021-04-12)

- New global configuration to be able to set the default log level and the conf
  check interval to other values than 1 and 10 seconds (see
  [console.conf](package-console.md#procedure-conf))
- Fixed: Saved call stack shows line numbers from the method console.assert
  instead of the calling code
- Some code refactoring

## v1.0-beta2 (2021-04-04)

First improvements after user feedback - thank you Dietmar (@daust):

- Splitting level verbose into debug and trace (we have now error, warning,
  info, debug and trace)
- Remove method permanent (is now a attribute in all log methods)
- Overload all log messages (procedure and function returning log_id)
- Improved docs to reflect the changes

## v1.0-beta1 (2021-03-14)

- First official beta version for collecting feedback from other users.

## countless alpha and beta versions with many api changes ;-)

- The CONSOLE was in heavy development. Therefore I did not update the
  changelog.

## v0.1-alpha (2021-01-05)

- First functional code.
