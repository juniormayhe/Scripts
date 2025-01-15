#!/bin/bash
RED='\033[1;31m'
CYAN='\033[1;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NO_COLOR='\033[0m'
CHECK="\u2714"

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
    echo -e "${CYAN}  ${message}"
    echo -e "--------------------------------------${NO_COLOR}"
}

display_success() {
    local message="$1"
    echo -e "${GREEN}${CHECK}  ${message}${NO_COLOR}"
}

display_error(){
    local message="$1"
    echo -e "${RED}ERROR: ${message}${NO_COLOR}"
}

is_port_in_use() {
    local port=$1
    if lsof -i:"$port" &>/dev/null; then
        return 0 # Port is in use
    else
        return 1 # Port is not in use
    fi
}

check_kubectl() {
    display_header "Checking Kubernetes"

    if ! command -v kubectl &> /dev/null; then
        display_error "kubectl is not installed. Please install it and try again."
        exit 1
    fi
}

cleanup() {
    display_header "Stopping all port-forwarding processes..."
    for pid in "${pids[@]}"; do
        kill "$pid" 2>/dev/null
    done
    display_success "All processes stopped. Exiting."
}


setup_port_forwarding() {

    display_header "Setting up port forwarding"

    # developer can also manually serve kubernetes pods with the following
    #kubectl port-forward svc/kubernetes-dashboard-kong-proxy 8443:443 -n kubernetes-dashboard
    #kubectl port-forward svc/schema-registry 8082:8081 -n trulabelsas
    #kubectl port-forward svc/control-center 9021:9021 -n trulabelsas
    #kubectl port-forward svc/mongodb 27017:27017 -n trulabelsas
    #kubectl port-forward svc/kafka 9092:9092 -n trulabelsas

    echo "Retrieving services from the Kubernetes cluster..."
    services=$(kubectl get services -A -o jsonpath='{range .items[*]}{.metadata.name} {.spec.ports[0].port} {.spec.ports[0].targetPort} {.metadata.namespace}{"\n"}{end}')

    if [[ -z "$services" ]]; then
        display_error "No services found in the Kubernetes cluster."
        exit 1
    fi

    echo "Setting up port forwarding for the following services:"
    echo "$services"

    forwarded_ports=()

    while IFS= read -r service; do
        name=$(echo "$service" | awk '{print $1}')
        port=$(echo "$service" | awk '{print $2}')
        target_port=$(echo "$service" | awk '{print $3}')
        namespace=$(echo "$service" | awk '{print $4}')

        # Handle Kafka service by checking for multiple ports
        if [[ "$name" == "kafka" ]]; then
            # Fetch Kafka ports and choose the last one (9092)
            ports=$(kubectl get svc kafka -o jsonpath='{.spec.ports[*].port}')
            port_array=($ports)
            last_port=${port_array[-1]}  # Get the last port (9092)
            target_port=$last_port
	        port=$target_port
        fi

    	if [[ "$name" == "kubernetes" ]]; then
           echo "Skipping $name as it is Kubernetes."
           continue
    	fi

        if [[ " ${forwarded_ports[@]} " =~ " $port " ]]; then
            echo "Port $port is already being forwarded. Skipping $name."
            continue
        fi

        if is_port_in_use "$port"; then
            echo "Port $port is already in use. Skipping $name."
        else
            echo "Forwarding $name: localhost:$port -> $target_port in namespace $namespace"
            kubectl port-forward svc/"$name" "$port":"$port" -n "$namespace" &

	        forwarded_ports+=("$port")
            pids+=($!)
        fi

    done <<< "$services"

    echo "Press any key to stop all port-forwarding processes..."
    read -n 1 -s
}

display_header "Serving Kubernetes resources to host computer..."

check_kubectl
setup_port_forwarding
trap cleanup EXIT
