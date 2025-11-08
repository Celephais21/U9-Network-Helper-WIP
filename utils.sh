#!/bin/bash
# shellcheck disable=SC2154

# Creates a list based on the variable "arrayList".
# This function only works correctly if arrayList comes before it with the value that should be listed.

#############
# UTILITIES #
#############

arrayCreatList() {
    local arrayContent
    local listNumber
    for arrayContent in "${arrayList[@]}"; do
        listNumber=$(( listNumber + 1))
        echo "[$listNumber] $arrayContent"
    done

}

# Breaks at most 2 loops if user confirms YES

userConfirmation() {
    while true; do
        local userConfirmInput
        read -r userConfirmInput
        if [[ $userConfirmInput == "YES" ]]; then
                return 0

        elif [[ $userConfirmInput == "no" ]]; then 
                echo " "
                return 1

        fi
    done

}

###########
# NETWORK #
###########

ipAddressInput() {
    local ipFormat
    local ipArray=()
    local octet
    local ipFormat='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
    while true; do
        read -p "IP address:" -r ipAddress
        echo " "

        IFS='.' read -ra ipArray <<< "$ipAddress"

        if [[ $ipAddress =~ $ipFormat ]]; then
            for octet in "${ipArray[@]}"; do
                if [[ $octet -le 254 ]]; then
                    
                    ipAddress=$(echo "$ipAddress" | IFS='.' sed -E 's/000|00/0/g')
                    return 0
                else

                    echo "An octet is higher than 254. Please try again."
                    break
                fi

            done
            continue
        else
            echo "Invalid format. Try again."
        fi
    done

}
netMaskInput() {
    local ipFormat
    local ipArray=()
    local octet
    local ipFormat='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
    while true; do
        read -p "Subnet Mask:" -r ipMask
        echo " "

        IFS='.' read -ra ipArray <<< "$ipMask"

        if [[ $ipMask =~ $ipFormat ]]; then
            for octet in "${ipArray[@]}"; do
                if [[ $octet -le 255 && $octet -ge 128 ]]; then
                    
                    return 0

                else

                    echo "One or more octets are either higher than 255 or lower 128. Please, try again."
                    break
                fi

            done
            continue
        else
            echo "Invalid format. Try again."
        fi
    done
}

