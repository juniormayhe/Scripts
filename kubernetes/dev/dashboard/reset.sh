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

display_header "- Resetting Pods from Kubernetes Dashboard"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    display_error "kubectl is not installed. Please install it and rerun the script."
    exit 1
fi

# Check if the kubernetes-dashboard namespace exists
if ! kubectl get namespace kubernetes-dashboard &> /dev/null; then
    display_error "The kubernetes-dashboard namespace does not exist. Please ensure the namespace exists."
    exit 1
fi


while true; do
    printf "${CYAN}Are you sure you want to reset ${YELLOW}kubernetes-dashboard${NO_COLOR}? ${YELLOW}Y${NO_COLOR}es/${YELLOW}N${NO_COLOR}o: "
    read user_input
    if [[ "$user_input" == "y" || "$user_input" == "yes" ]]; then
        echo
        display_warning "Restarting pods. Please WAIT 15 seconds or more until this process finishes..."
        kubectl delete pods --all -n kubernetes-dashboard
        display_success "All pods in the kubernetes-dashboard namespace have been deleted."
        
        echo
        printf "${CYAN}Your new pods in the kubernetes-dashboard namespace are:${NO_COLOR}\n"
        kubectl get pods -n kubernetes-dashboard
        break
    elif [[ "$user_input" == "n" || "$user_input" == "no" ]]; then
        display_warning "Operation aborted."
        break
    else
        display_error "Invalid choice. Please enter 'Y' or 'N'."
    fi
done
echo
exit 0
