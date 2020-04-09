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
```
kubectl proxy
```

5) Visit the dashboard url and paste the token copied previously to proceed with login

http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

## Creating an alias for kubectl command

Create a batch / cmd file and save to a known path such as `C:\Users\%username%\AppData\Local\Microsoft\WindowsApps`
```
@echo off
doskey k=kubectl $*
```
And open a new command prompt to test the alias
```
k --help
k get pods
```

## Creating pods

To create a nginx pod with the podname my-nginx
```
k run my-nginx --image=nginx:alpine
```

To list the resources (pod name and deployment name)
```
k get all

NAME                            READY   STATUS    RESTARTS   AGE
pod/my-nginx-6c79cbc966-5t58q   1/1     Running   0          15s


NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   4h32m


NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-nginx   1/1     1            1           110s

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/my-nginx-6c79cbc966   1         1         1       110s
```

To forward port from external localhost:8080 to container:80 and be able to browse localhost:8080
```
k port-forward my-nginx-6c79cbc966-5t58q 8080:80
```

To delete the pod (the pod will be restaured to its latest state if you run k get all or k get pods)
```
k delete pod my-nginx-6c79cbc966-5t58q
```

To permanent delete the pod deployment, enter the deployment name 
```
k delete deployment my-nginx
```
