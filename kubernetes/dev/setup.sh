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

display_header "saas - Setting up Kubernetes environment"
display_message "${YELLOW}To skip confirmations in the future, run ${NO_COLOR}./setup.sh -y"
prompt_user "Press ENTER key to update Linux or CTRL+C to abort" 120

# -----------------------------------
display_message "📦 Updating Linux on WSL..."

sudo apt update -y
sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl gnupg xclip

if [ $? -ne 0 ]; then
    display_error "Failed to update Linux on WSL."
    echo -e "Exiting the script."
    exit 1
fi

display_success "Linux on WSL updated."


prompt_user "Press ENTER key to prepare certificate or CTRL+C to abort" 120

# -----------------------------------
display_message "🏅 Installing certificate..."
CERT_CONTENT=$(cat <<EOF
-----BEGIN CERTIFICATE-----
MIIE0zCCA7ugAwIBAgIJANu+mC2Jt3uTMA0GCSqGSIb3DQEBCwUAMIGhMQswCQYD
VQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTERMA8GA1UEBxMIU2FuIEpvc2Ux
FTATBgNVBAoTDFpzY2FsZXIgSW5jLjEVMBMGA1UECxMMWnNjYWxlciBJbmMuMRgw
FgYDVQQDEw9ac2NhbGVyIFJvb3QgQ0ExIjAgBgkqhkiG9w0BCQEWE3N1cHBvcnRA
enNjYWxlci5jb20wHhcNMTQxMjE5MDAyNzU1WhcNNDIwNTA2MDAyNzU1WjCBoTEL
MAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExETAPBgNVBAcTCFNhbiBK
b3NlMRUwEwYDVQQKEwxac2NhbGVyIEluYy4xFTATBgNVBAsTDFpzY2FsZXIgSW5j
LjEYMBYGA1UEAxMPWnNjYWxlciBSb290IENBMSIwIAYJKoZIhvcNAQkBFhNzdXBw
b3J0QHpzY2FsZXIuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
qT7STSxZRTgEFFf6doHajSc1vk5jmzmM6BWuOo044EsaTc9eVEV/HjH/1DWzZtcr
fTj+ni205apMTlKBW3UYR+lyLHQ9FoZiDXYXK8poKSV5+Tm0Vls/5Kb8mkhVVqv7
LgYEmvEY7HPY+i1nEGZCa46ZXCOohJ0mBEtB9JVlpDIO+nN0hUMAYYdZ1KZWCMNf
5J/aTZiShsorN2A38iSOhdd+mcRM4iNL3gsLu99XhKnRqKoHeH83lVdfu1XBeoQz
z5V6gA3kbRvhDwoIlTBeMa5l4yRdJAfdpkbFzqiwSgNdhbxTHnYYorDzKfr2rEFM
dsMU0DHdeAZf711+1CunuQIDAQABo4IBCjCCAQYwHQYDVR0OBBYEFLm33UrNww4M
hp1d3+wcBGnFTpjfMIHWBgNVHSMEgc4wgcuAFLm33UrNww4Mhp1d3+wcBGnFTpjf
oYGnpIGkMIGhMQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTERMA8G
A1UEBxMIU2FuIEpvc2UxFTATBgNVBAoTDFpzY2FsZXIgSW5jLjEVMBMGA1UECxMM
WnNjYWxlciBJbmMuMRgwFgYDVQQDEw9ac2NhbGVyIFJvb3QgQ0ExIjAgBgkqhkiG
9w0BCQEWE3N1cHBvcnRAenNjYWxlci5jb22CCQDbvpgtibd7kzAMBgNVHRMEBTAD
AQH/MA0GCSqGSIb3DQEBCwUAA4IBAQAw0NdJh8w3NsJu4KHuVZUrmZgIohnTm0j+
RTmYQ9IKA/pvxAcA6K1i/LO+Bt+tCX+C0yxqB8qzuo+4vAzoY5JEBhyhBhf1uK+P
/WVWFZN/+hTgpSbZgzUEnWQG2gOVd24msex+0Sr7hyr9vn6OueH+jj+vCMiAm5+u
kd7lLvJsBu3AO3jGWVLyPkS3i6Gf+rwAp1OsRrv3WnbkYcFf9xjuaf4z0hRCrLN2
xFNjavxrHmsH8jPHVvgc1VD0Opja0l/BRVauTrUaoW6tE+wFG5rEcPGS80jjHK4S
pB5iDj2mUZH1T8lzYtuZy0ZPirxmtsk3135+CKNa2OCAhhFjE0xd
-----END CERTIFICATE-----
EOF
)

# Create the certificate file
CERT_ENTRY="SHA-256_Z-Scaler_Root_Certificate.crt"
echo "$CERT_CONTENT" | sudo tee "/tmp/$CERT_ENTRY" > /dev/null

# Move the certificate file to the appropriate directory
sudo mv -f "/tmp/$CERT_ENTRY" "/usr/share/ca-certificates/$CERT_ENTRY" || { echo "Failed to move certificate file"; exit 1; }

# Create a symbolic link
sudo ln -s "/usr/share/ca-certificates/$CERT_ENTRY" "/etc/ssl/certs/$CERT_ENTRY" || { display_warning "Failed to create symbolic link. Maybe it already exists.";  }

# Update the CA certificates configuration
CA_CONF_FILE="/etc/ca-certificates.conf"

# Check if the entry already exists
if ! grep -Fxq "$CERT_ENTRY" "$CA_CONF_FILE"; then
    # Entry does not exist, append it to the file
    echo "$CERT_ENTRY" | sudo tee -a "$CA_CONF_FILE" || { echo "Failed to update CA certificates configuration"; exit 1; }
    display_success "CA certificates configuration updated successfully."
else
    display_warning "Certificate already exists in CA certificates configuration."
fi

# Update the CA certificates
sudo update-ca-certificates

if [ $? -ne 0 ]; then
    display_error "Failed to update certificates."
    echo -e "Exiting the script."
    exit 1
fi

display_success "Certificate installed successfully."

prompt_user "Press ENTER key to setup Kubernetes or CTRL+C to abort" 120
# -----------------------------------
display_message "🎡 Installing Kubernetes..."

# Create the keyrings directory and download the GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/$(curl -sL https://dl.k8s.io/release/stable.txt | sed -E 's/\.[0-9]+$//')/deb/Release.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
if [ $? -ne 0 ]; then
    display_error "Failed to download the release key for Kubernetes."
    display_error "Check if the file exists https://pkgs.k8s.io/core:/stable:/$(curl -sL https://dl.k8s.io/release/stable.txt | sed -E 's/\.[0-9]+$//')/deb/Release.key"
    echo -e "Exiting the script."
    exit 1
fi


# Set the correct permissions for the GPG key
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Download the kubectl binary
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install the kubectl binary
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Verify the kubectl installation
kubectl version --client

if [ $? -ne 0 ]; then
    display_error "Failed to install Kubernetes"
    echo -e "Exiting the script."
    exit 1
fi

display_success "Kubernetes installed successfully."


prompt_user "Press ENTER key to setup Docker or CTRL+C to abort" 120

# -----------------------------------
display_message "🐋 Installing Docker..."

curl -fsSL -A "Mozilla/5.0" https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io


sudo usermod -aG docker $USER
display_warning "You may need to close the terminal and reopen it later, to run docker commands without sudo."
sudo systemctl enable docker
sudo systemctl start docker
sudo docker --version

if [ $? -ne 0 ]; then
    display_error "Failed to install Docker."
    echo -e "Exiting the script."
    exit 1
fi

display_success "Docker installed successfully."

prompt_user "Press ENTER key to setup KinD to create kubernetes cluster or CTRL+C to abort" 120

# -----------------------------------
display_message "🚢 Installing KinD..."
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

CLUSTER_NAME="kind"
if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
    display_warning "Cluster '${CLUSTER_NAME}' already exists."
else
    kind create cluster -n "${CLUSTER_NAME}"
fi

if [ $? -ne 0 ]; then
    display_error "Failed to install KinD."
    echo -e "Exiting the script."
    exit 1
fi

display_success "KinD installed successfully."

prompt_user "Press ENTER key to apply deployments to Kubernetes or CTRL+C to skip" 120
SCRIPT_DIR=$(dirname "$(realpath "$0")")
display_message "🔍 Validating Kubernetes manifests in '${SCRIPT_DIR}/kubernetes'... "
if ! kubectl apply -k "${SCRIPT_DIR}/kubernetes" --dry-run=client &>/dev/null; then
    echo -e "${RED}FAILED${NO_COLOR}"
    display_error "Validation failed. Check your Kustomization setup or YAML files in './kubernetes'."
    exit 1
fi
display_success "Kubernetes manifests in '${SCRIPT_DIR}/kubernetes' are OK"
echo

display_message "📃 Applying Kubernetes manifests in '${SCRIPT_DIR}/kubernetes'... "
kubectl apply -k "${SCRIPT_DIR}/kubernetes"
if [ $? -ne 0 ]; then
    display_error "Failed to apply manifests in Kubernetes."
    echo -e "Exiting the script."
    exit 1
fi
display_success "Deployments applied to Kubernetes successfully."

echo
display_warning "Please note that the first time you set up your cluster, it may take 7-10 minutes to be fully ready."

echo
display_message "${CYAN}Run ${NO_COLOR}./serve.sh ${CYAN}to expose your apps to your host computer${NO_COLOR}"
display_message "${CYAN}Run ${NO_COLOR}./delete.sh ${CYAN}if you want to remove Kubernetes cluster${NO_COLOR}"
display_message "${CYAN}Run ${NO_COLOR}./dashboard/add.sh ${CYAN}if you want a dashboard for Kubernetes${NO_COLOR}"
echo

# try to switch user to the namespace that hosts applications
NAMESPACE_FILE="$SCRIPT_DIR/kubernetes/namespace.yaml"
if [ ! -f "$NAMESPACE_FILE" ]; then
    display_error "Error: Namespace file '$NAMESPACE_FILE' does not exist."
    exit 1
else

    NAMESPACE=$(grep -i "name:" "$NAMESPACE_FILE" | awk '{print $2}' | tr -d '\r' | tr -d '\n')
    if [ -z "$NAMESPACE" ]; then
        display_error "Error: Failed to extract namespace name from '$NAMESPACE_FILE'."
        exit 1
    fi
    display_message "Namespace that hosts applications: $NAMESPACE"
    kubectl config set-context --current --namespace="${NAMESPACE}"

    if [ $? -eq 0 ]; then
        display_success "Successfully switched context to namespace: $NAMESPACE"
        echo
        display_message "${CYAN}To see application pods run:${NO_COLOR} kubectl get pods"
        display_message "${CYAN}To see pod logs run:${NO_COLOR} kubectl logs <POD_ID> <-c CONTAINER_NAME> -f"
        display_message "${CYAN}To restart a pod run:${NO_COLOR} kubectl delete pod <POD_ID>"
        
    else
        display_error "Error: Failed to switch context to namespace: $NAMESPACE"
    fi
fi

echo
echo "Done!"
echo
