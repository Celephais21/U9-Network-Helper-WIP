#!/bin/bash

# Main script for U9Installer.
# This script call for other functions and makes the initial configuration for the script
# Author: Celephais.
# Version: 0.1
# Usage: (WIP).
# Example: (WIP).



# Sources relevant files.
source ./tools.sh
source ./utils.sh
source ./config.sh
source ./variables.sh





# Greets the user and gives them the following options: 1 for adapter config, 2 for apt config and 3 for DHCP config.
greeting

# Selects the tool based on the user's input from the previous function.

case "$helperOptionSelected" in

        0) networkHelper

esac




