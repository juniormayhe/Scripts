#!/bin/bash
RED='\033[1;31m'
CYAN='\033[1;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NO_COLOR='\033[0m'
CHECK="✓"

prompt_user() {
    local message="$1"
    local timeout="$2"

    echo -e "${CYAN}"
    read -t "$timeout" -p "$message" user_input
    echo -e "${NO_COLOR}"

    user_input=$(echo "$user_input" | tr '[:upper:]' '[:lower:]')

    if [[ "$user_input" == "y" || "$user_input" == "yes" ]]; then
        return 0
    else
        echo "Operation aborted."
        exit 1
    fi
}

display_header() {
    local message="$1"
    echo -e "${CYAN}--------------------------------------"
    echo -e "${CYAN}${message}"
    echo -e "--------------------------------------${NO_COLOR}"
}

display_success() {
    local message="$1"
    echo -e "${GREEN}${CHECK} ${message}${NO_COLOR}"
}

display_warning(){
    local message="$1"
    echo -e "${YELLOW}WARNING: ${message}${NO_COLOR}"
}

display_error(){
    local message="$1"
    echo -e "${RED}ERROR: ${message}${NO_COLOR}"
}

display_message() {
    local message="$1"
    local nonewline="${2:-}"
    if [ -z "$nonewline" ]; then
        printf "${NO_COLOR}${message}\n${NO_COLOR}"
    else
        printf "${NO_COLOR}${message}${NO_COLOR}"
    fi
}

display_header "- Restarting Pods"
echo -e "${CYAN}Press CTRL+C to abort${NO_COLOR}"

# Check for command-line arguments
if [ "$#" -eq 1 ]; then
    if [[ "$1" == "-a" || "$1" == "-A" ]]; then
        # Restart all pods
        display_warning "Restarting pods. Please WAIT 30 seconds or more until this process finishes..."
        kubectl delete pods --all
        display_success "All pods have been restarted."

        echo
        printf "${CYAN}Your new pods are:${NO_COLOR}\n"
        kubectl get pods
        echo
        exit 0
    fi
fi

if [ "$#" -eq 2 ]; then
    if [[ "$1" == "-s" || "$1" == "-S" ]]; then
        POD_SUBSTRING=$2
        # Restart single pod
        echo
        kubectl get pods | awk "NR==1 || /${POD_SUBSTRING}/"
        echo

        # Find the pod name
        POD_NAME=$(kubectl get pods -o jsonpath="{.items[*].metadata.name}" | tr -s '[[:space:]]' '\n' | grep -i "$POD_SUBSTRING" | head -n 1)
        if [ -z "$POD_NAME" ]; then
            display_warning "No pod found containing the substring: $POD_SUBSTRING"
            exit 1
        else
            display_warning "Restarting pod. Please WAIT until this process finishes..."
            kubectl delete pod $POD_NAME
            display_success "Pod $POD_NAME has been restarted."
            echo
                    
        fi
        exit 0
    fi
fi

# no command line args provided
while true; do
    printf "${CYAN}Restart all pods or a specific pod? ${NO_COLOR}${YELLOW}A${NO_COLOR}ll/${YELLOW}S${NO_COLOR}${NO_COLOR}pecific: "
    read choice

    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

    if [[ "$choice" == "a" || "$choice" == "all" ]]; then
        # Restart all pods
        display_warning "Restarting pods. Please WAIT 30 seconds or more until this process finishes..."
        kubectl delete pods --all
        display_success "All pods have been restarted."

        echo
        printf "${CYAN}Your new pods are:${NO_COLOR}\n"
        kubectl get pods
        echo
        break
    elif [[ "$choice" == "s" || "$choice" == "specific" ]]; then
        # Restart single pod
        echo
        kubectl get pods
        echo
        while true; do
            printf "${CYAN}Enter the pod name substring: ${NO_COLOR}"
            read POD_SUBSTRING

            # Find the pod name
            POD_NAME=$(kubectl get pods -o jsonpath="{.items[*].metadata.name}" | tr -s '[[:space:]]' '\n' | grep -i "$POD_SUBSTRING" | head -n 1)
            if [ -z "$POD_NAME" ]; then
                display_warning "No pod found containing the substring: $POD_SUBSTRING"
            else
                display_message "Pod: ${YELLOW}$POD_NAME${NO_COLOR}"

                while true; do
                    printf "${CYAN}Are you sure you want to restart the pod ${YELLOW}$POD_NAME${NO_COLOR}? ${YELLOW}Y${NO_COLOR}es/${YELLOW}N${NO_COLOR}o: "
                    read user_input

                    user_input=$(echo "$user_input" | tr '[:upper:]' '[:lower:]')

                    if [[ "$user_input" == "y" || "$user_input" == "yes" ]]; then
                        echo
                        display_warning "Restarting pod. Please WAIT until this process finishes..."
                        kubectl delete pod $POD_NAME
                        display_success "Pod $POD_NAME has been restarted."
                        break
                    elif [[ "$user_input" == "n" || "$user_input" == "no" ]]; then
                        display_warning "Operation aborted."
                        break
                    else
                        display_error "Invalid choice. Please enter 'Y' or 'N'."
                    fi
                done
                break
            fi
        done
        break
    else
        display_error "Invalid choice. Please enter 'A' or 'S'."
    fi
done
echo
