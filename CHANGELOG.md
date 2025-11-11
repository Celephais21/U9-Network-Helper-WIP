# Changelog


## Version 0.2.3 [11-11-25]
- Warns the user if the specified path in config.conf contains the interfaces file (Currently, used for testing only).
- If the script is executed as sudo, immediatly ends the execution.
- [*DEV*] The old config.sh was changed into config.conf in order to make variables there permanent.

## Version 0.2.2 [11-09-25]
- Correct the problem where the code allowed to input invalid address in the submask (Ex: 128.0.255.0, 12.0.0.0).
- [*DEV*] Added a calculator that extracts how many bits are used for hosts and for the network for future use.

## Version 0.1.0 [11-08-25]
- Start of the project.