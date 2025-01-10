#!/bin/bash

is_port_in_use() {
    local port=$1
    if lsof -i:"$port" &>/dev/null; then
        return 0 # Port is in use
    else
        return 1 # Port is not in use
    fi
}

check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo "kubectl is not installed. Please install it and try again."
        exit 1
    fi
}

setup_port_forwarding() {
    echo "Retrieving services from the Kubernetes cluster..."
    services=$(kubectl get services -o jsonpath='{range .items[*]}{.metadata.name} {.spec.ports[0].port} {.spec.ports[0].targetPort} {.metadata.namespace}{"\n"}{end}')

    if [[ -z "$services" ]]; then
        echo "No services found in the Kubernetes cluster."
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

cleanup() {
    echo "Stopping all port-forwarding processes..."
    for pid in "${pids[@]}"; do
        kill "$pid" 2>/dev/null
    done
    echo "All processes stopped. Exiting."
}

# Main script logic
check_kubectl
setup_port_forwarding
trap cleanup EXIT
