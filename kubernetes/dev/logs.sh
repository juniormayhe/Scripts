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

display_message() {
    local message="$1"
    local nonewline="${2:-}"
    if [ -z "$nonewline" ]; then
        printf "${NO_COLOR}${message}\n${NO_COLOR}"
    else
        printf "${NO_COLOR}${message}${NO_COLOR}"
    fi
}

display_header "- Logs"
if [ -z "$1" ]; then
  echo "Usage: $0 <pod_name_substring>"
  exit 1
fi

POD_SUBSTRING=$1
POD_NAME=$(kubectl get pods -o jsonpath="{.items[*].metadata.name}" | tr -s '[[:space:]]' '\n' | grep -i "$POD_SUBSTRING" | head -n 1)
if [ -z "$POD_NAME" ]; then
  display_warning "No pod found containing the substring: $POD_SUBSTRING"
  exit 1
fi
display_message "Pod: ${YELLOW}$POD_NAME${NO_COLOR}"

display_message "${CYAN}Press CTRL+C to abort${NO_COLOR}\n\n" 120
kubectl logs $POD_NAME --tail=10 -f

echo
