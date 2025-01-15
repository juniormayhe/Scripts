RED='\033[1;31m'
CYAN='\033[1;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
CHECK="\u2714"

# Setup Kafka
echo -e "\nSetting up your environment"
echo -e "\n${YELLOW}ATTENTION: if you have any previous cluster setup on a different port, remove them all or reset Kubernetes Cluster in Docker before proceeding.${NC}"

# Dev user must have setup the NUGET PAT (key)
echo -e "${CYAN}--------------------------------------"
echo "Checking environment variables"
echo -e "--------------------------------------${NC}"
if [[ -z "${NUGET_PAT}" ]]; then
  echo -e "${RED}"
  echo -e "The NUGET_PAT environment variable was not found. Exiting the script.${NC}"
  exit 1
else
  echo -e "${GREEN}${CHECK} The NUGET_PAT environment variable found: ${NUGET_PAT}${NC}"
fi

echo -e "${CYAN}"
read -t 120 -p "Press ENTER key to setup MongoDB or CTRL C to abort" user_input
echo -e "${NC}"

echo -e "${CYAN}--------------------------------------"
echo "Setting up MongoDB pod"
echo -e "--------------------------------------${NC}"
kubectl apply -k ./LocalEnvironment/k8s-mongodb-statefulset
if [ $? -ne 0 ]; then
  echo -e "${RED}"
  echo "ERROR: cannot run kubectl apply -k ./LocalEnvironment/k8s-mongodb-statefulset"
  echo -e "Exiting the script.${NC}"
  exit 1
else
  echo -e "${GREEN}${CHECK} kubectl apply -k ./LocalEnvironment/k8s-mongodb-statefulset${NC}"
fi

#kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s
#echo "Sleeping for 120 seconds"
#sleep 120
echo -e "${CYAN}"
read -t 120 -p "Press ENTER key to setup MongoDB cluster or CTRL C to abort" user_input
echo -e "${NC}"

echo -e "${CYAN}--------------------------------------"
echo "Setting up MongoDB cluster"
echo -e "--------------------------------------${NC}"
kubectl exec -i mongo-0 -- bin/mongosh --eval '
rs.initiate(
  {
    _id: "rs0",
    members: [
      { _id: 0, host : "mongo-0.mongo:27017" },
    ]
  }
);
'
sleep 5

# Add mongo-1 as a secondary member of the replica set
echo "Adding mongo-1 as secondary..."
kubectl exec -i mongo-0 -- bin/mongosh --eval '
rs.add("mongo-1.mongo:27017")
'
sleep 5

echo ""
output=$(kubectl exec -i mongo-0 -- bin/mongosh --eval "rs.status()")
if echo "$output" | grep -q 'health: 1' && echo "$output" | grep -q 'ok: 1'; then
    echo -e "${GREEN}${CHECK} Mongo created!${NC}"
else
    echo -e "${RED}ERROR: Please review mongo creation${NC}"
    echo -e "Exiting the script.${NC}"
    exit 1
fi

echo -e "${CYAN}"
read -t 120 -p "Press ENTER key to setup Kafka or CTRL C to abort" user_input
echo -e "${NC}"

echo -e "${CYAN}--------------------------------------"
echo "Setting up Kafka"
echo -e "--------------------------------------${NC}"
echo "Creating directories"
mkdir -p /c/kafka
mkdir -p /c/kafka/data
mkdir -p /c/zookeeper
mkdir -p /c/zookeeper/data
mkdir -p /c/zookeeper/log
kubectl apply -k ./LocalEnvironment/k8s-kafka
if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: cannot run kubectl apply -k ./LocalEnvironment/k8s-kafka"
    echo -e "The kubectl command failed. Exiting the script.${NC}"
    exit 1
else
  echo -e "${GREEN}${CHECK} kubectl apply -k ./LocalEnvironment/k8s-kafka${NC}"
  echo -e "${GREEN}${CHECK} Kafka setup done${NC}"
fi

kubectl apply -f ./LocalEnvironment/k8s-ingress
if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: cannot run kubectl apply -f ./LocalEnvironment/k8s-ingress"
    echo -e "The kubectl command failed. Exiting the script.${NC}"
    exit 1
else
  echo -e "${GREEN}${CHECK} kubectl apply -f ./LocalEnvironment/k8s-ingress${NC}"
  echo -e "${GREEN}${CHECK} Kafka setup done${NC}"
fi

echo -e "${CYAN}"
read -t 120 -p "Press ENTER key to build docker images or CTRL C to abort" user_input
echo -e "${NC}"

echo -e "${CYAN}--------------------------------------"
echo "Building docker images"
echo -e "--------------------------------------${NC}"
# declare -a arr=( "ServiceName")
# for i in "${arr[@]}"
# do
# done
docker-compose -f "./Docker/docker-compose.yaml" build
if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: cannot run docker-compose -f \"./Docker/docker-compose.yaml\" build"
    echo -e "The docker-compose command failed. Exiting the script.${NC}"
    exit 1
else
  echo -e "${GREEN}${CHECK} docker-compose -f \"./Docker/docker-compose.yaml\" build${NC}"
  echo -e "${GREEN}${CHECK} Docker images setup done${NC}"
fi

echo -e "${CYAN}"
read -t 120 -p "Press ENTER key to deploy docker images or CTRL C to abort" user_input
echo -e "${NC}"

echo -e "${CYAN}--------------------------------------"
echo "Deploying images to kubernetes"
echo -e "--------------------------------------${NC}"
kubectl apply -k "./k8s/base"
if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: cannot run kubectl apply -k \"./k8s/base\""
    echo -e "The kubectl command failed. Exiting the script.${NC}"
    exit 1
else
  echo -e "${GREEN}${CHECK} kubectl apply -k \"./k8s/base\"${NC}"
  echo -e "${GREEN}${CHECK} Docker images deployed${NC}"
fi
echo "Done!"
