#!/bin/bash
#shellcheck disable=SC2034
#

# Option that decides which helper will be used.
helperOptionSelected=1

# Identify what tool is being started.
helperConfigStarterPhrase=("Adapter Configuration" "Repository Change" "DHCP Helper ")

# Used by stringExtractor to separate a string into different values
extractString="none"

# Used by stringExtractor to output a string.
#declare -a outputArray

# Used by userConfirm function
userConfirm=0

###########
# NETWORK #
###########

# Whatever or not the card is going to use DHCP
useDhcp=false

# Used by the ipAddressInput to store IP.
ipAddress=0

# Used by netMaskInput to store subnet IP.
ipMask=0

# Used for the network IP and Broadcast, respectfully.
ipNetwork=0
ipBroadcast=0

# Used as input for binary calculator
decimalInput=()

# Used as output for binary calculator. Counts only bits used by the network.
binaryOutputNetwork=()

# Used as output for binary calculator. Counts only bits used by the hosts.
binaryOutputHosts=()

# If the amount of network bits in an octet is needed.
_octetNBits=0

# Used in case amount of hosts is needed
hostAmount=0