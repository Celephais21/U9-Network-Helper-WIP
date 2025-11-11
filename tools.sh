#!/bin/bash
# shellcheck disable=SC2154

source ./variables.sh
source ./utils.sh
source ./config.conf

# This script stores all the fundamental functions used on main.sh

# Greets the user and asks what function from U9Installer they will use.
greeting () {

        if [[ $firstStart = true ]]; then

                printf "It seems like this is the first time you are starting the program.\n"
                if [[ ! -e $INTERFACES_FOLDER/test.txt ]]; then 


                        printf "The %s does not contain the 'interfaces' file\n" "$INTERFACES_FOLDER"
                        printf "Please, verify the specified path and try again.\n"
                        return 1
                

                fi

                cp config.conf config.temp
                sed -i  's/firstStart=true/firstStart=false/g' ./config.conf

        else
               
               if [[ ! -e $INTERFACES_FOLDER/test.txt ]]; then 


                        printf "The %s does not contain the 'interfaces' file\n" "$INTERFACES_FOLDER"
                        printf "Please, verify the specified path and try again\n"
                        return 1

                fi 

        fi


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
        local _userInput2="none" # In case userInput is not available (might get removed later)
        

        # Lists all interfaces that are DOWN and put them on ethernetCards array.
        read -ra ethernetCards <<< "$(ip a | grep "DOWN" | awk '{print $2}' | tr -d ':' | tr "\n" ' ')"


        # Allows user to pick an option
        while true; do
        
        printf "The following cards' state is DOWN. Please chose one to start the configuration.\n"
        printf "*WARNING! The card state might be DOWN for other reasons other than lack of configuration. Proceed at your own risk!\n"
         
         # List all unconfigured ethernet cards for the user.
        arrayList=("${ethernetCards[@]}")
        arrayCreateList

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
        
        # Decides if configuration is going to use dhcp or not
        echo "Is the card going to use DHCP?[YES/no]"; if userConfirmation; then useDhcp=true; fi
        
        # Static IP configuration and configuration finisher.

        while true; do
                if [[ $useDhcp == true ]]; then

                        printf "The following changes will be written:\n\n"

                        printf "\n\n# Network card '%s' dhcp configuration\n" "${ethernetCards[$userInput]}"
                        printf "auto %s\n" "${ethernetCards[$userInput]}"
                        printf "iface %s inet dhcp\n\n" "${ethernetCards[$userInput]}"

                        printf "Proceed with this cinfiguration?[YES/no]"

                       

                        if userConfirmation; then

                                sudo bash -c '
                                        # Creates backup of Interfaces file
                                        cp "$INTERFACES_FOLDER/test.txt" "$INSTANCE_FOLDER/test.bkp"
                                        
                                        {
                                        printf "\n\n# Network card '%s' dhcp configuration\n" "${ethernetCards[$userInput]}"
                                        printf "auto %s\n" "${ethernetCards[$userInput]}"
                                        printf "iface %s inet dhcp" "${ethernetCards[$userInput]}"  
                                        } >> "$INSTANCE_FOLDER/test.txt"
                                        echo " "
                                '
                        fi

                        return 0
                # Continue to static IP configuration.
                else
                        
                        echo "Input network information for static IP configuration." 
                        ipAddressInput
                        netMaskInput

                        # Set up variable for use in 'broadcast' and 'network'.
                        ipNetwork=$ipAddress
                        ipNetwork=$(echo "$ipNetwork" | awk -F '.' -v OFS='.' '{$4=0; print}')
                        ipBroadcast=$ipAddress
                        ipBroadcast=$(echo "$ipNetwork" | awk -F '.' -v OFS='.' '{$4=255; print}')

                        # Adds all the configuration to file
                        printf "The configuration bellow will be written. Do you wish to continue?[YES/no]\n\n"


                        printf "auto %s\n" "${ethernetCards[$userInput]}"
                        printf "iface %s inet static\n" "${ethernetCards[$userInput]}"

                        printf "address %s\n" "$ipAddress"
                        printf "netmask %s\n" "$ipMask"
                        printf "network %s\n" "$ipNetwork"
                        printf "broadcast %s\n" "$ipBroadcast"

                        if userConfirmation; then
                                 sudo bash -c '
                                        # Creates backup of Interfaces file
                                        cp "$INSTANCE_FOLDER/test.txt" "$INSTANCE_FOLDER/test.bkp"
                                        {

                                        printf "\n\n# Network card '%s' static IP configuration\n" "${ethernetCards[$userInput]}"
                                        printf "auto %s\n" "${ethernetCards[$userInput]}"
                                        printf "iface %s inet static" "${ethernetCards[$userInput]}"
                
                                        printf "address %s\n" "$ipAddress" 
                                        printf "netmask %s\n" "$ipMask"
                                        printf "network %s\n" "$ipNetwork"
                                        printf "broadcast %s\n" "$ipBroadcast"
                                        } >> "$INSTANCE_FOLDER/test.txt" 
                                '
                                echo "Static Network configuration finished. Leaving..."

                                break
                        fi

                fi

        done
        

}