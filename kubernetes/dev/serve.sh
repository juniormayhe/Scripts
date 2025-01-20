#!/bin/bash

RED='\033[1;31m'
CYAN='\033[1;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NO_COLOR='\033[0m'
CHECK="✓"

pids=()
forwarded_ports=()

display_header() {
    local message="$1"
    echo -e "${CYAN}--------------------------------------"
    echo -e "${CYAN}  ${message}"
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

display_error() {
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

is_port_in_use() {
    local port=$1
    if lsof -i:"$port" &>/dev/null; then
        return 0 # Port is in use
    else
        return 1 # Port is not in use
    fi
}

kill_port() {
    local port=$1
    if is_port_in_use "$port"; then
        display_warning "Port $port is in use. Killing the process using this port..."
        lsof -t -i:"$port" | xargs kill -9
        if is_port_in_use "$port"; then
            display_error "Failed to kill the process using port $port."
            return 1
        else
            display_success "Successfully killed the process using port $port."
            return 0
        fi
    else
        return 0
    fi
}

check_kubectl() {
    display_message "🔍 Checking Kubernetes..." "nonewline"

    if ! command -v kubectl &> /dev/null; then
        display_error "kubectl is not installed. Please install it and try again."
        exit 1
    fi
    echo -e "${GREEN}OK${NO_COLOR}"
}

cleanup() {
    echo
    display_warning "Stopping all port-forwarding processes..."
    for pid in "${pids[@]}"; do
        kill "$pid" 2>/dev/null
    done
    display_success "All processes stopped. Exiting."
}

setup_port_forwarding() {
    display_message "Setting up port forwarding"
    display_warning "Press CTRL+C to stop this script..."
    echo

    # Define your services and ports to be exposed to host computer
    # <service name> <external port> <internal port> <namespace>
    services=(
        "mongodb 27017 27017 saas"
        "kafka 9092 9092 saas"
        "schema-registry 8082 8081 saas"
        "control-center 9021 9021 saas"
    )

    for service in "${services[@]}"; do
        name=$(echo "$service" | awk '{print $1}')
        port=$(echo "$service" | awk '{print $2}')
        target_port=$(echo "$service" | awk '{print $3}')
        namespace=$(echo "$service" | awk '{print $4}')

        if [[ " ${forwarded_ports[@]} " =~ " $port " ]]; then
            display_error "Port $port is already being forwarded. Skipping $name."
            continue
        fi

        if ! kill_port "$port"; then
            display_error "Failed to kill the process using port $port. Skipping $name."
            continue
        fi

        echo "Forwarding $name: localhost:$port -> $target_port in namespace $namespace"
        kubectl port-forward svc/"$name" "$port":"$target_port" -n "$namespace" &

        forwarded_ports+=("$port")
        pids+=($!)
    done

    echo "Press Ctrl+C to stop all port-forwarding processes..."
    wait
}

trap cleanup EXIT

display_header "- Serving Kubernetes resources to host computer..."

check_kubectl
setup_port_forwarding
