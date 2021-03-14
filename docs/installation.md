# Installation

## One Minute Installation

Open SQLcl, connect to your desired install schema and call
`@https://raw.githubusercontent.com/ogobrecht/console/main/install/create_console_objects.sql`

## Normal Installation

[Clone the repository](https://github.com/ogobrecht/console) or download the
[latest
version](https://github.com/ogobrecht/oracle-instrumentation-console/releases/latest)
and unzip it.

The installation itself is splitted into one mandatory and three optional steps:

1. Install CONSOLE itself
    - Start SQL*Plus and connect to your desired install schema
    - Run `@install/create_console_objects.sql`
    - User needs the rights to create packages, tables and scheduler jobs
    - Do this step on every new release of CONSOLE
2. Optional: Create a context
    - For performance reasons this is recommended, but it will work without a
      context
    - Start SQL*Plus and connect to a privileged user
    - Run `@install/create_context.sql "YOUR_CONSOLE_INSTALL_SCHEMA"`
    - Maybe your DBA needs to do that for you once
3. Optional: Grant rights to client schema
    - When installed in a central tools schema you may want to grant execute
      rights on the package and select rights on the log table to public or
      other schemas
    - Start SQL*Plus and connect to your CONSOLE install schema
    - Run `@install/grant_rights.sql "YOUR_CLIENT_SCHEMA"`
4. Optional: Create synonyms in client schema(s)
    - When you want to use it in another schema you may want to create synonyms
      there or public ones for easier access
    - Maybe you want also different names for your synonyms like `log` instead
      of `console`
    - As this step is very variable you should create a reusable script by
      yourself...

## Uninstallation

Hopefully you will never need it...

As with the installation the uninstallation is splitted into multiple steps:

1. Drop the CONSOLE objects
    - Start SQL*Plus and connect to your CONSOLE install schema
    - Run `@uninstall/drop_console_objects.sql`
2. Drop the context (if you have one)
    - Start SQL*Plus and connect to a privileged user
    - Run `@uninstall/drop_context.sql "YOUR_CONSOLE_INSTALL_SCHEMA"`
    - Maybe your DBA needs to do that for you
3. Drop synonyms in client schemas
    - You know, if you created synonyms and how they were named...