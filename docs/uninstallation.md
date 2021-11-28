<!-- nav -->

[Index](README.md)
| [Installation](installation.md)
| [Introduction](introduction.md)
| [API Overview](api-overview.md)
| [Package Console](package-console.md)
| [Changelog](changelog.md)
| [Uninstallation](uninstallation.md)

<!-- navstop -->

# Uninstallation

Hopefully you will never need it...

As with the installation the uninstallation is splitted into multiple steps:

1. Drop the CONSOLE objects
    - Start SQL*Plus and connect to your CONSOLE install schema
    - Run `@uninstall/drop_console_objects.sql`
2. Drop synonyms in client schemas
    - You know, if you created synonyms and how they were named...

A T T E N T I O N: If you have installed one of the beta versions and created a
context, you should also delete it: `@uninstall/drop_context.sql` (you may need higher
permissions for this...).
