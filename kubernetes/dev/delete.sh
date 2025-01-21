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
    echo -e "\n${CYAN}------------------------------------------"
    echo -e "${CYAN}${message}"
    echo -e "------------------------------------------${NO_COLOR}"
}

display_success() {
    local message="$1"
    echo -e "${GREEN}${CHECK} ${message}${NO_COLOR}"
}

display_error(){
    local message="$1"
    echo -e "${RED}ERROR: ${message}${NO_COLOR}"
}

display_warning(){
    local message="$1"
    echo -e "${YELLOW}WARNING: ${message}${NO_COLOR}"
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

display_header "TruLabelSAS - Removing Kubernetes Dashboard"

display_message "🔍 Check for Helm installation... " "nonewline"
if ! command -v helm &> /dev/null; then
    display_error "Helm is not installed. Please install it and rerun the script."
    exit 1
fi
echo -e "${GREEN}OK${NO_COLOR}"

display_message "🔍 Check for Kubernetes installation... " "nonewline"
if ! command -v kubectl &> /dev/null; then
    display_error "kubectl is not installed. Please install it and rerun the script."
    exit 1
fi
echo -e "${GREEN}OK${NO_COLOR}"


if ! kubectl get namespace kubernetes-dashboard &>/dev/null; then
    echo
    display_warning "Namespace 'kubernetes-dashboard' does not exist or cluster is unreachable. Skipping uninstallation."
else
    
    prompt_user "Press ENTER key to remove dashboard or CTRL+C to abort" 120
    # Remove the Kubernetes dashboard using Helm
    display_message "Removing Kubernetes Dashboard..."
    
    if helm list --namespace kubernetes-dashboard | grep -q kubernetes-dashboard; then
        if helm uninstall kubernetes-dashboard --namespace kubernetes-dashboard &>/dev/null; then
            display_success "Kubernetes dashboard uninstalled successfully."
        else
            echo
            display_error "Failed to uninstall Kubernetes dashboard."
        fi
    else
        echo
        display_warning "Kubernetes dashboard not found."
    fi
fi

prompt_user "Press ENTER key to remove namespace for dashboard or CTRL+C to abort" 120

# Delete the Kubernetes dashboard namespace
display_message "🧹 Deleting Kubernetes Dashboard Namespace. Please wait... "

if ! kubectl delete namespace kubernetes-dashboard --ignore-not-found &>/dev/null; then
    display_error "Failed to delete namespace 'kubernetes-dashboard'."
else
    display_success "Namespace deleted"
fi

# Remove the admin-user ServiceAccount, Secret, and RoleBinding if they exist
echo
display_message "🧹 Removing Admin User Resources... "
if ! kubectl delete serviceaccount admin-user -n kubernetes-dashboard --ignore-not-found &>/dev/null; then
    echo
    display_error "Failed to delete serviceaccount 'admin-user'."
else
    display_success "Service account deleted"
fi

if ! kubectl delete secret admin-user -n kubernetes-dashboard --ignore-not-found &>/dev/null; then
    display_error "Failed to delete secret for 'admin-user'."
else
    display_success "Secret deleted"
fi

if ! kubectl delete clusterrolebinding admin-user --ignore-not-found &>/dev/null; then
    display_error "Failed to delete clusterrolebinding for 'admin-user'."
else
    display_success "Cluster role binding removed"
fi
echo
display_message "🔍 Verifying Cleanup... "

if ! kubectl get all -n kubernetes-dashboard &>/dev/null; then
    display_warning "Some resources might still be present.\nCheck manually with ${NO_COLOR}kubectl get all -n kubernetes-dashboard."
else
    display_success "Everything is fine"
fi

echo
echo "Done!"
echo
