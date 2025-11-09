#!/bin/bash
# shellcheck disable=SC2154

# Creates a list based on the variable "arrayList".
# This function only works correctly if arrayList comes before it with the value that should be listed.

#############
# UTILITIES #
#############

arrayCreateList() {
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

    # Variable for the IPv4 format.
    local ipFormat='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
    
    while true; do
        read -p "IP address:" -r ipAddress
        echo " "

        # Puts the Address into an array so it can be readable by the program
        IFS='.' read -ra ipArray <<< "$ipAddress"

        # Checks if user input follow propper format.
        if [[ $ipAddress =~ $ipFormat ]]; then
            for octet in "${ipArray[@]}"; do
                
                # Prevents any octet from being higher than 254
                if [[ $octet -le 254 ]]; then
                    
                    # If any octet contains '000' or '00' changes to a single 0.
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

    local ipFormat=""
    local ipArray=()
    local octet=""
    
    # Variables used in the old binary calculator system when the binary calculator worked within the Network Input.
    # Might get removed eventually.
    # local _octetExtractedBits=0
    # local _octetsBitsAmount=() 
    
    # Variable will be "spent" to acquire bits.

    # local octetProcessed=""

    local ipFormat='^([1-9]{3}\.){3}[1-9]{3}|[0]{1}$' # I may make this into a global variable.

    while true; do

        # Input and validate mask
        while true; do
            
            # Global variable is ipMask for subnet masks
            read -p "Subnet Mask:" -r ipMask
            echo " "
            
            # Removes dots and input all octets into the ipArray.
            IFS='.' read -ra ipArray <<< "$ipMask"

            # Input ip into calculator
            decimalInput=("${ipArray[@]}")
            

            
            # Verify if IP follows propper Format
            if [[ $ipMask =~ $ipFormat ]]; then
                
                binaryCalculator
        
                # Variables used to validate mask.
                local iterationsCounter=0
                local lastOctet=0


                # Validates each octet
                for octet in "${ipArray[@]}"; do
                    
                    if [[ $lastOctet -lt 255 && $octet -ge $lastOctet && $lastOctet -ne 0 ]]; then
                        printf "The octet '%s' makes the mask not contiguous. Plase, try again.\n" "$octet"
                        break
                

                    elif [[ $(( 256 % (256 - octet ) )) -eq 0 && $octet -ge 128 && $octet -le 255 ]]; then
                        
                        lastOctet=$octet
                        iterationsCounter=$(( iterationsCounter + 1 ))
                        

                    elif [[ $octet -eq 0 ]]; then
                        
                        lastOctet=$octet
                        iterationsCounter=$(( iterationsCounter + 1 ))
                        
                    
                    else
                        
                        printf "The octet '%s' is lower than 128 or not contiguous. Try again\n" "$octet"
                        break
                    fi

                    if [[ $iterationsCounter -eq 4 ]]; then
                        break 2
                    fi
            
                # All octets are valid.
                done
            
            else
                
                printf "The address does not follow propper format. Please try again.\n"

            # The IP has been validated.    
            fi
        # IP input no longer necessary.
        done

        # Calculates how many hosts the mask will have.
        for octet in "${binaryOutputHosts[@]}"; do
                
            hostAmount=$(( octet + hostAmount ))
            
    
        done
        hostAmount=$(( (2 ** hostAmount) - 2 ))

        # Gives extra information for the user

        if [[ $hostAmount -le 4 ]]; then
            
            printf "The subnet can only support %s\n" "$hostAmount"
            printf "Proceed anyway?[Yes/no]\n"

            if userConfirmation; then

                return 0

            fi
        
        else 
            
            printf "Subnet mask has %s usable hosts\n" "$hostAmount"
            printf "Is this acceptable?[YES/no]\n"
            
            if userConfirmation; then
                return 0
            fi

        fi

    done


}

# Inputs an IP and outputs the amount of bits that are "1" (Network bits)
binaryCalculator() {


    local octetProcessed
    local octetExtractedNBits
    local octetExtractedHBits
    local octetsNBitsAmount 
    local octetsHBitsAmount

    # Verify if $octet var already exists. If not, create it.
    if [[ ! -v $octet ]]; then
        local octet

    fi

    # Start of the calculator.
    for octet in "${decimalInput[@]}"; do
           
            # Transfer values to $octetProcessed in case $octet is used elsewhere.
            octetProcessed=$octet

            # If the octet is 0, then all bits are used for host
            if [[ "$octetProcessed" -eq 0 ]]; then octetExtractedHBits=8; fi

            # 
            while [ "$octetProcessed" -gt 0 ]; do

                # Counts only the bits that are positive (network bits).
                if [[ $(( octetProcessed % 2)) = 1 ]]; then
                    
                    
                    octetExtractedNBits=$(( octetExtractedNBits + 1 ))

                # Counts only the bits that are 0 (Host bits)
                elif [[ $(( octetPrcessed % 2 )) = 0 ]]; then

                    octetExtractedHBits=$(( octetExtractedHBits + 1 ))
                    
                fi

                ((octetProcessed >>= 1 ))

            done
            

            #Adds a each new bit as a separete value to $octetsBitsAmount
            octetsNBitsAmount+=("$octetExtractedNBits")

            octetsHBitsAmount+=("$octetExtractedHBits")

            octetExtractedNBits=0 # Reset so it can count the bits again.
            octetExtractedHBits=0
            
    done
    
    # Transfer values from the temporary variable to the global one (might remove later).
    binaryOutputNetwork=( "${octetsNBitsAmount[@]}" )
    binaryOutputHosts=( "${octetsHBitsAmount[@]}" )

}

##############
# Deprecated #
##############



# Old netMaskInput. Became unused due to input problems.
old_netMaskInput() {
    local ipFormat
    local ipArray=()
    local octet
    
    # Variable used to verify available hosts.
    local ipSum=0
    local ipHostsAmount=0
    local ignoreMessage=false
    
    local ipFormat='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
    
    while true; do

        # Global variable is ipMask for subnet mask
        read -p "Subnet Mask:" -r ipMask
        echo " "

        

        IFS='.' read -ra ipArray <<< "$ipMask"
        
        # Finds how many hosts are inside the subnet by subtracting the sum of all the octets minus 256*4.
        for octet in "${ipArray[@]}"; do
            
            ipSum=$(( ipSum + octet ))

        done

        ipHostsAmount=$(( ( 256 * 4 ) - ipSum ))

        echo "$ipHostsAmount"

        if [[ $ipMask =~ $ipFormat ]]; then
            for octet in "${ipArray[@]}"; do

                # Prevents user from using values that do not follow expected standars.

                if [[ $octet -le 255 && $(( 256 % ( 256 - octet ) )) -eq 0 ]]; then
                    
                    printf "%d" "$(( 256 % ( 256 - octet ) ))"
                    # If the subnet gives four or less hosts, throws a warning.
                    if [[ $ipHostsAmount -lt 4 && $ignoreMessage = false ]]; then
                            
                            printf "Current subnet has only %s hosts. Do you want to continue?[YES/no]" "$ipHostsAmount"
                            if userConfirmation; then ignoreMessage=true; else break; fi
                            
                    fi

                else

                    echo "One or more octets are invalid. Please try again."
                    break
                fi


            done
            continue
        else
            echo "Invalid format. Try again."
        fi
    done
}