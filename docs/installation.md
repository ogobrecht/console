<!-- nav -->

[Index](README.md)
| [Installation](installation.md)
| [Introduction](introduction.md)
| [API Overview](api-overview.md)
| [Package Console](package-console.md)
| [Changelog](changelog.md)
| [Uninstallation](uninstallation.md)

<!-- navstop -->

# Installation

A T T E N T I O N: If you have one of the beta versions installed you should
always run the uninstallation script (`@uninstall/drop_console_objects.sql`)
before you install a new version. If you created a context, you should also
delete it: `@uninstall/drop_context.sql` (you may need higher permissions for this...).

## One Minute Installation

Open SQLcl, connect to your desired install schema and call
`@https://raw.githubusercontent.com/ogobrecht/console/main/install/create_console_objects.sql`

## Normal Installation

[Clone the repository](https://github.com/ogobrecht/console) or download the
[latest
version](https://github.com/ogobrecht/oracle-instrumentation-console/releases/latest)
and unzip it.

The installation itself is splitted into one mandatory and two optional steps:

1. Install CONSOLE itself
    - Start SQL*Plus and connect to your desired install schema
    - Run `@install/create_console_objects.sql`
    - User needs the rights to create packages, tables and scheduler jobs
    - Do this step on every new release of CONSOLE
2. Optional: Grant rights to client schema
    - When installed in a central tools schema you may want to grant execute
      rights on the package and select rights on the log table to public or
      other schemas
    - Start SQL*Plus and connect to your CONSOLE install schema
    - Run `@install/grant_rights.sql "YOUR_CLIENT_SCHEMA"`
3. Optional: Create synonyms in client schema(s)
    - When you want to use it in another schema you may want to create synonyms
      there or public ones for easier access
    - Maybe you want also different names for your synonyms like `log` instead
      of `console`
    - As this step is very variable you should create a reusable script by
      yourself...
