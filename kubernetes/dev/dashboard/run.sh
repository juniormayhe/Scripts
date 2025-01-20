#!/bin/bash
RED='\033[1;31m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NO_COLOR='\033[0m'
CHECK="✓"

SKIP_PROMPTS=false
if [[ "${1,,}" == "-y" ]]; then
    SKIP_PROMPTS=true
fi

prompt_user() {
    local message="$1"
    local timeout="$2"

    if [ "$SKIP_PROMPTS" = true ]; then
        echo -e "${NO_COLOR}"
        return
    fi

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

kill_port() {
    local port="$1"
    local pid=$(lsof -t -i :"$port")
    if [ -n "$pid" ]; then
        display_warning "Killing existing process on port $port (PID: $pid)"
        kill -9 "$pid"
    fi
}

display_header "- Running Kubernetes Dashboard"

URL="https://localhost:8443"

if ! command -v kubectl &> /dev/null; then
    display_error "ERROR: kubectl is not installed. Please install it and rerun the script."
    exit 1
fi

if ! command -v kind &> /dev/null; then
    display_error "ERROR: kind is not installed. Please install it and rerun the script."
    exit 1
fi

# Check if the kubernetes-dashboard namespace exists
if ! kubectl get namespace kubernetes-dashboard &> /dev/null; then
    display_error "ERROR: The kubernetes-dashboard namespace does not exist. Please ensure the dashboard is installed and the namespace exists."
    exit 1
fi

# Kill any existing process on port 8443
kill_port 8443

display_message "🎛️ Starting kubectl port-forward in the background..."
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443 &

# print and copy the secret to the clipboard
K8S_DASH_SECRET=$(kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath="{.data.token}" | base64 -d)
echo "$K8S_DASH_SECRET" | xclip -selection clipboard
echo
display_success "Dashboard secret copied to clipboard:"
echo -e "${YELLOW}${K8S_DASH_SECRET}${NO_COLOR}"

PORT_FORWARD_PID=$!
cmd.exe /c start "$URL"

echo "Press CTRL+C to stop the port-forward and release the port."
wait $PORT_FORWARD_PID

echo "Port-forward stopped. Exiting the script."
echo "Done!"
echo
exit 0
