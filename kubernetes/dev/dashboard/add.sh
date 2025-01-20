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

display_header "SAS - Adding Kubernetes Dashboard"

prompt_user "Press ENTER key to check Kubernetes installation or CTRL+C to abort" 120

# -----------------------------------
display_message "🎡 Checking Kubernetes..." "nonewline"
if ! command -v kubectl &> /dev/null; then
    display_error "kubectl is not installed. Please install it and rerun the script."
    exit 1
fi
echo -e "${GREEN}OK${NO_COLOR}"

# -----------------------------------
display_message "🚢 Checking KinD..." "nonewline"
if ! command -v kind &> /dev/null; then
    display_error "KinD is not installed. Please install it and rerun the script."
    exit 1
fi
echo -e "${GREEN}OK${NO_COLOR}"

# -----------------------------------
display_message "🎛️ Installing Kubernetes dashboard..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
rm ./get_helm.sh

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: v1
kind: Secret
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: "admin-user"
type: kubernetes.io/service-account-token
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

if [ $? -ne 0 ]; then
    display_error "Failed to install Kubernetes dashboard."
    echo -e "Exiting the script."
    exit 1
fi
echo
display_success "Kubernetes dashboard installed successfully."

# print and copy the secret to the clipboard
K8S_DASH_SECRET=$(kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath="{.data.token}" | base64 -d)
echo "$K8S_DASH_SECRET" | xclip -selection clipboard
echo
display_success "Dashboard secret copied to clipboard:"
echo -e "${YELLOW}${K8S_DASH_SECRET}${NO_COLOR}"
echo
echo "Done!"
echo
