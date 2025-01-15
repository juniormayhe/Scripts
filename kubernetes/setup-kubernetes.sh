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
    echo -e "${CYAN}${message}"
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

display_header "Starting Kubernetes environment setup"

prompt_user "Press ENTER key to update Linux or CTRL C to abort" 120

# -----------------------------------
display_header "Updating Linux on WSL 📦"

sudo apt update -y
sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl gnupg xclip

if [ $? -ne 0 ]; then
    display_error "Failed to update Linux on WSL."
    echo -e "Exiting the script."
    exit 1
fi

display_success "Linux on WSL updated."


prompt_user "Press ENTER key to prepare certificate or CTRL C to abort" 120

# -----------------------------------
display_header "Installing certificate 🏅"
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
sudo ln -s "/usr/share/ca-certificates/$CERT_ENTRY" "/etc/ssl/certs/$CERT_ENTRY" || { echo "Failed to create symbolic link. Maybe it already exists.";  }

# Update the CA certificates configuration
CA_CONF_FILE="/etc/ca-certificates.conf"

# Check if the entry already exists
if ! grep -Fxq "$CERT_ENTRY" "$CA_CONF_FILE"; then
    # Entry does not exist, append it to the file
    echo "$CERT_ENTRY" | sudo tee -a "$CA_CONF_FILE" || { echo "Failed to update CA certificates configuration"; exit 1; }
    echo "CA certificates configuration updated successfully."
else
    echo "Entry already exists in CA certificates configuration."
fi

# Update the CA certificates
sudo update-ca-certificates || { echo ""; exit 1; }

if [ $? -ne 0 ]; then
    display_error "Failed to update certificates."
    echo -e "Exiting the script."
    exit 1
fi

display_success "Certificate installed successfully."

prompt_user "Press ENTER key to setup Kubernetes or CTRL C to abort" 120
# -----------------------------------
display_header "Installing Kubernetes 🎡"

# Create the keyrings directory and download the GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/$(curl -ksL https://dl.k8s.io/release/stable.txt | sed 's/\.0$//')/deb/Release.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Set the correct permissions for the GPG key
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Download the kubectl binary
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install the kubectl binary
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify the kubectl installation
kubectl version --client

if [ $? -ne 0 ]; then
    display_error "Failed to install Kubernetes"
    echo -e "Exiting the script."
    exit 1
fi

display_success "Kubernetes installed successfully."


prompt_user "Press ENTER key to setup Docker or CTRL C to abort" 120

# -----------------------------------
display_header "Installing Docker 🐋"

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io


sudo usermod -aG docker $USER
echo "You may need to close the terminal and reopen it later, to run docker commands without sudo."
sudo systemctl enable docker
sudo systemctl start docker
sudo docker --version

if [ $? -ne 0 ]; then
    display_error "Failed to install Docker."
    echo -e "Exiting the script."
    exit 1
fi

display_success "Docker installed successfully."

prompt_user "Press ENTER key to setup KinD to create kubernetes cluster or CTRL C to abort" 120

# -----------------------------------
display_header "Installing KinD 🚢"
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

CLUSTER_NAME="kind"
if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
    echo "Cluster '${CLUSTER_NAME}' already exists."
else
    kind create cluster -n "${CLUSTER_NAME}"
fi

kubectl cluster-info -–context kind-kind

kubectl get all -A
if [ $? -ne 0 ]; then
    display_error "Failed to install KinD."
    echo -e "Exiting the script."
    exit 1
fi

display_success "KinD installed successfully."

prompt_user "Press ENTER key to apply deployments to Kubernetes or CTRL C to abort" 120

# -----------------------------------
display_header "Applying deployments 📃"

# Define the sequence of YAML files
yaml_files=(
    "namespace.yaml"
    "zookeeper.yaml"
    "kafka.yaml"
    "schema-registry.yaml"
    "control-center.yaml"
    #"init-topics.yaml" #uncomment if you want to create your topics 
    "mongo.yaml"
    "init-mongo.yaml"
    #"kubernetes-dashboard.yaml"
)

for file in "${yaml_files[@]}"; do
    echo "Applying $file..."
    kubectl apply -f "$file"
    if [ $? -ne 0 ]; then
        display_error "Failed to apply $file"
        echo -e "Exiting the script."
        exit 1
    fi
done

display_success "Deployments applied to Kubernetes successfully."

prompt_user "Press ENTER key to setup Kubernetes dashaboard or CTRL C to abort" 120

# -----------------------------------
display_header "Installing Kubernetes dashboard 🎛️"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard

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

# Get the secret and decode it, then store it in a variable
K8S_DASH_SECRET=$(kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath="{.data.token}" | base64 -d)

# Copy the secret to the clipboard
echo "$K8S_DASH_SECRET" | xclip -selection clipboard

display_success "Dashboard secret copied to clipboard:"
echo -e "$K8S_DASH_SECRET"


if [ $? -ne 0 ]; then
    display_error "Failed to install KinD."
    echo -e "Exiting the script."
    exit 1
fi

display_success "KinD installed successfully."

echo "Done!"
