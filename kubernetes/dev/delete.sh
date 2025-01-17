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
    echo -e "${NC}"

    if [ -n "$user_input" ]; then
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

display_header "- Removing Kubernetes"
display_warning "This will remove ALL resources from Kubernetes"
prompt_user "Press ENTER key to delete KinD cluster or CTRL+C to abort" 120

kind delete cluster -n kind
if [ $? -ne 0 ]; then
    display_error "Failed to remove KinD cluster."
fi

display_success "Resources removed."
echo
