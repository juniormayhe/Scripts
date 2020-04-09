# Kubernetes commands

## Installing

- Enable Kubernetes option in Docker Desktop and wait the restart after applying changes

## Enable kubernetes dashboard
1) Deploy a dashboard ui
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml
```

2) Show the authorization token for the service account
```
kubectl describe secret -n kube-system
```

3) Copy the authorization token
```
Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  11 bytes
token:      eyJhbGciOiJSUzI1N.... << copy this
```

4) Run the kubernetes proxy to host the dashboard ui

kubectl proxy

5) Visit the dashboard url and paste the token copied previously to proceed with login

http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
