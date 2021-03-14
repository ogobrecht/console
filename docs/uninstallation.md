# Uninstallation

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
