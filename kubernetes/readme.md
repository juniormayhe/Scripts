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

## Pods
### Creating an alias for kubectl command

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

### Creating pods

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

### Create a pod using yaml
Edit a nginx.pod.yml
```
apiVersion: v1
kind: Pod
metadata:
  name: my-nginx
  labels: # labels allow deployments or labels to reference this kubernetes resource
    app: ningx
    rel: stable
spec:
  containers:
  - name: my-nginx
    image: nginx:alpine
    ports:
    - containerPort: 80 # this is overkill and not necessary but illustrates we can change port
    livenessProbe: # used to determine if pod is healthy and running as expected and when to restart the container if needed, custom changes to the container are lost
      httpGet: # http check action for index.html on port 80
        path: /index.html
        port: 80
      initialDelaySeconds: 15 # wait 15 seconds before first liveness probe, so container can have time to start
      timeoutSeconds: 2 # timeout after 2 seconds. Default timeout is 1 sec
      periodSeconds: 5 # check every 5 seconds. Default period is 10 sec
      failureThreshold: 1 # allow 1 failure before failing the pod and restart it (default behaviour). Default threshold is 3
    readinessProbe: # when should traffic start being routed to this pod
      httpGet:
        path: /index.html
        port: 80
      initialDelaySeconds: 2 # wait 2 seconds for the pod to respond
      periodSeconds: 5 # check every 5 seconds until app is up and running
```

Test pod creation with yaml
```
kubectl create -f nginx.pod.yml --dry-run --validate=true
```

Create a pod
```
kubectl create -f nginx.pod.yml
```

Create a pod using yaml and add annotation about current yaml version
```
kubectl create -f nginx.pod.yml --save-config
```
then if we change the container image or other setting (except port), with 
```
kubectl apply -f nginx.pod.yml
```
apply it will compare the new with current version and create a new pod up and running

Edit in live while running and save it using vi
```
kubectl edit -f ngginx.pod.yml
```

### Show events run about the pod, container and image used during creation
```
kubectl describe pod my-nginx
```

### Enter the container s.o
```
kubectl exec my-nginx -it sh
```

### Delete container
since there is no deployment, a delete will permanente delete the pod by name or using YAML file that created it
```
kubectl delete pod my-nginx or
kubectl delete -f nginx.pod.yml
```

## Deployments
### Create a deployment with replicaset to handle the pods with container template
Edit the deployment file
```
apiVersion: apps/v1
kind: Deployment
metadata: # labels can be used for querying multiple resources
  name: frontend # the name of deployment
  labels:
    app: my-nginx
    tier: frontend # used to tie the deployment to the template
spec:
  replicas: 5
  minReadySeconds: 10 # the pod wait the container start for 10 seconds to start receiving traffic
  selector: # used to select the template to use
    matchLabels:
      tier: frontend # look down 
  template: # template used to create the pod container (selector label matches the template label)
    metadata:
      labels:
        tier: frontend
    spec:
      containers:
      - name: my-nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        resources:
          limits:
            memory: "128Mi" # 128 MB
            cpu: "200m" #200 millicpu (.2 cpu / 20% of the cpu)
        livenessProbe:
          httpGet:
            path: /index.html
            port: 80
          initialDelaySeconds: 15 # wait 15 seconds before first probe
          timeoutSeconds: 2 # time to wait of 2 seconds for a response
          periodSeconds: 2 # wait 2 seconds for next probe
          failureThreshold: 1 # restart after 1 failed probe
```

Create a deployment
```
kubectl create -f nginx-deployment.yaml
```

You can use apply, if the deployment must have been created preserving metadata version annotations with `kubectl create -f nginx-deployment.yaml --save-config`
```
kubectl apply -f nginx-deployment.yaml
```

Get all deployment info and their labels

```
kubectl get deployment --show-labels
```

Get deployment info with a specific label
```
kubectl get deployment -l app=my-nginx
```

### Delete deployment
```
kubectl delete deployment deployname or kubectl delete deployment -f nginx-deployment.yaml
```

### Fast scale deployment pods and enter number of pods / 5 containers
```
kubectl scale deployment deployname --replicas=5 or kubectl scale deployment -f nginx-deployment.yaml --replicas=5
```
or add `replicas: 5` within `spec:` property then run to apply changes to deployment
```
kubectl apply -f nginx-deployment.yaml 
```

## Liveness probe

### Create or update a pod if existing

```
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-exec
spec:
  containers:
  - name: liveness
    image: k8s.gcr.io/busybox
    args: # command to be executed when container starts
    - /bin/sh
    - -c
    - touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 5 # during first 30 seconds there is a file and cat will return success, when removed, a failure
    livenessProbe:
      exec:
        command: # in the first probe there will be a file within 30 seconds, and no errors
                 # and after 35 seconds a nex probe is done but the file is gone, and error will show up and machine will be restarted
                 # several restarts should happen or restarts only 3 times?
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5 # kubelet waits 5 seconds before first probe
      periodSeconds: 5 # kubelet checks every 5 seconds
      #failureThreshold: 3 is the defaut, after the 3rd liveness probe the container is restarted. Restarts happens repeatedly
```
```
kubectl apply -f livenessprobe-execaction.yaml
```

Within 30 seconds, you see the file has been created
```
kubectl describe pod liveness-exec
```

or check restarts on realtime with 
```
kubectl get pod liveness-exec --watch
```

## Port fowarding

To access a pod from outside kubernetes, listening to 8080 externally and forwarding to internal 80 in pod
```
kubectl port-forward pod/<pod-name> 8080:80
```

To access a deployment from outside kubernetes, listening to 8080 externally and forwarding to deployment´s pod
```
kubectl port-forward deployment/<deployment-name> 8080 (if the pod internally also uses 8080)
kubectl port-forward deployment/<deployment-name> 8080:80 (if the pod internally also uses 80)
```

To access a service from outside kubernetes, listening to 8080 externally and forwarding to service´s pod
```
kubectl port-forward service/<service-name> 8080
```

## Services

### Creating services
Edit the service file
```
apiVersion: apps/v1
kind: Service
metadata: # labels can be used for querying multiple resources
  name: nginx # the name of service and it gets a dns entry
  labels:
    app: nginx
spec:
  type: # ClusterIP (default), NodePort, LoadBalancer
  selector: # used to select the pod template to use this service applies to
    app: nginx # service to apply to resources
  ports:
  - name: http
    port: 80 # service port
    targetPort: 80 # container target port
  
  
  
  template: # template used to create the pod container (selector label matches the template label)
    metadata:
      labels:
        app: my-nginx
    spec:
      containers:
      - name: my-nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        resources:
          limits:
            memory: "128Mi" # 128 MB
            cpu: "200m" #200 millicpu (.2 cpu / 20% of the cpu)
        livenessProbe:
          httpGet:
            path: /index.html
            port: 80
          initialDelaySeconds: 15 # wait 15 seconds before first probe
          timeoutSeconds: 2 # time to wait of 2 seconds for a response
          periodSeconds: 2 # wait 2 seconds for next probe
          failureThreshold: 1 # restart after 1 failed probe
```
