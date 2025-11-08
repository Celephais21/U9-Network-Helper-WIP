#!/bin/bash
# shellcheck disable=SC2154

source ./variables.sh
source ./utils.sh
source ./config.sh

# This script stores all the fundamental functions used on main.sh

# Greets the user and asks what function from U9Installer they will use.
greeting () {

    local option="none"
    local optionNumber=0

    printf "You are using version %s of U9Installer.\n" "$version"
    printf "Please, select one of the options below:\n"
    
    # Give each option a number.
    for option in "${CONF_OPTIONS[@]}"; do
            optionNumber=$(( optionNumber + 1 ))
            echo "[$optionNumber] $option"
            
    done

    # Check if option typed is valid
    while true; do

            read -r helperOptionSelected
            if [[ "$helperOptionSelected" =~ ^[1-3]$ && $helperOptionSelected -le 3 ]]; then
                    helperOptionSelected=$(( helperOptionSelected - 1 ))
                    printf "Starting %s...\n\n" "${helperConfigStarterPhrase[$helperOptionSelected]}"            
                    break
            else

                echo "Invalid input. Please try again."
                
            fi


    done
}


# Network Card configuration helper

networkHelper(){
        

        # Array used for all cards that are not configured
        declare -a ethernetCards

        # local variable for all user inputs.
        local userInput="none"
        local userInput2="none" # In case userInput is not available
        

        # Lists all interfaces that are DOWN and put them on ethernetCards array.
        read -ra ethernetCards <<< "$(ip a | grep "DOWN" | awk '{print $2}' | tr -d ':' | tr "\n" ' ')"


        # Allows user to pick an option
        while true; do
        
        printf "The following cards' state is DOWN. Please chose one to start the configuration.\n"
        printf "*WARNING! The card state might be DOWN for other reasons other than lack of configuration. Proceed at your own risk!\n"
         
         # List all unconfigured ethernet cards for the user.
        arrayList=("${ethernetCards[@]}")
        arrayCreatList

                read -r userInput
                userInput=$(( userInput - 1 ))

                # Confirms user's choice
                if [[ $userInput =~ ^[0-${#ethernetCards}] ]]; then
                        printf "Is this the correct card? [YES/no]: %s\n" "${ethernetCards[$userInput]}"
                        
                        # If user's is certain of their choice, leave while loop
                        
                        if userConfirmation; then
                                break 2
                        fi

                else
                        printf "\e[31mIncorrect input, please try again.\n\n\e[0m"
                fi
        done
        
        # Creates backup of Interfaces file
        cp "$INSTANCE_FOLDER/test.txt" "$INSTANCE_FOLDER/test.bkp"

        # Decides if configuration is going to use dhcp or not
        echo "Is the card going to use DHCP?[YES/no]"
                if userConfirmation; then
                        {
                        printf "\n\n# Network card '%s' dhcp configuration\n" "${ethernetCards[$userInput]}"
                        printf "auto %s\n" "${ethernetCards[$userInput]}"
                        printf "iface %s inet dhcp" "${ethernetCards[$userInput]}"  
                        } >> "$INSTANCE_FOLDER/test.txt"
                        useDhcp=true
                else
                        {
                        printf "\n\n# Network card '%s' static IP configuration\n" "${ethernetCards[$userInput]}"
                        printf "auto %s\n" "${ethernetCards[$userInput]}" >> "$INSTANCE_FOLDER/test.txt"
                        printf "iface %s inet static" "${ethernetCards[$userInput]}" >> "$INSTANCE_FOLDER/test.txt" 
                        } >> "$INSTANCE_FOLDER/test.txt"  
                fi
        # If using DHCP, no more configuration is needed.
        
        while true; do
                if [[ $useDhcp == true ]]; then

                        echo "Interface configuration for card was succesful!"
                        echo "Would you like to see your configuration file?[YES/no]"

                        if userConfirmation; then
                                cat "$INSTANCE_FOLDER/test.txt"
                                echo " "
                        fi

                        return 0
                # Continue to static IP configuration.
                else
                        
                        echo "Input network information for static IP configuration." 
                        ipAddressInput
                        netMaskInput

                        # Set up variable for use in broadcast and network.
                        ipNetwork=$ipAddress
                        ipNetwork=$(echo "$ipNetwork" | awk -F '.' -v OFS='.' '{$4=0; print}')
                        ipBroadcast=$ipAddress
                        ipBroadcast=$(echo "$ipNetwork" | awk -F '.' -v OFS='.' '{$4=255; print}')

                        # Adds all the configuration to file
                        printf "The configuration bellow will be written. Do you want to continue?[YES/no]\n\n"
                        printf "address %s\n" "$ipAddress"
                        printf "netmask %s\n" "$ipMask"
                        printf "network %s\n" "$ipNetwork"
                        printf "broadcast %s\n" "$ipBroadcast"

                        if userConfirmation; then
                                {
                                printf "address %s\n" "$ipAddress" 
                                printf "netmask %s\n" "$ipMask"
                                printf "network %s\n" "$ipNetwork"
                                printf "broadcast %s\n" "$ipBroadcast"
                                } >> "$INSTANCE_FOLDER/test.txt"

                                echo "Static Network configuration finished. Leaving..."

                                break
                        fi

                fi

        done
        

}