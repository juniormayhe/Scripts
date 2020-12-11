# Scaling down .net core applications

This document shows some findings related to scaling down containerized netcore applications in a Kubernetes cluster. 

## Evaluated termination signals
First thing first, let’s review how termination signals work:

A SIGTERM signal is sent to the main process (PID 1) in each container, and a “grace period” countdown starts defaults to 30 seconds, but you can extend this time by adding a setting it in Kubernetes deployment file.

Upon the reception of the SIGTERM, each container should start a graceful shutdown of the running application and exit.

If a container doesn’t terminate within the grace period, a SIGKILL signal will be sent and the container violently terminated.

Ref: https://pracucci.com/graceful-shutdown-of-kubernetes-pods.html

The net core application can gradually shutdown when SIGTERM or SIGINT are received from its container.

The signal codes evaluated in this investigation are:

| Signal name  | Signal value  | Effect  |
|---|---|---|
| SIGINT  | 2  |  Kubernetes says “could you please stop what you are doing?” and sends an interrupt from keyboard message (aka CTRL + C). The netcore application has a chance to do some cleanup and graceful shutdown. |
| SIGKILL  | 9  |  Kubernetes lost its patience and shut down the container and interrupts whatever its netcore app is doing. |
| SIGTERM  | 15  |  Kubernetes asks for termination of the process but gives a chance for a cleanup and a graceful netcore application shutdown.  |


## Preparing the evaluation
To evaluate the netcore application shutdown we used the following tools:

- [bombardier](https://github.com/codesenberg/bombardier) - for sending requests and testing load balancer
- [postman](https://www.postman.com/downloads/) - for sending requests
- [docker for windows](https://docs.docker.com/docker-for-windows/install/) - for enabling a local Kubernetes environment with kubectl containerized net core 3.1 app
- Kubernetes declarative management files - for creating cluster

## Scenarios
We have identified some basic evaluated scenarios and outcomes:

|Scenario   | Result  |
|---|---|
| Scale down on default cluster and netcore app with default configurations  |  The netcore app responds to all requests |
| Scale down on default cluster and netcore app with thread sleep on application stopping event  |  The netcore app responds to all requests |
| Scale down on default cluster and netcore app with increased timeout  | The netcore app responds to all requests  |

## Evidences

### Boilerplates
Here are the sample files used in the evaluation

Default cluster: k8s-deployment-myapi.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mydeployment
spec:
  replicas: 2
  selector:
      matchLabels:
        name: mykubapp
  template:
    metadata:
      labels:
        name: mykubapp
    spec:
      containers:
        - name: myapi
          image: juniormayhe/myapi:1
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
    name: mykubapp
spec:
  ports:  
    - protocol: TCP
      port: 8080
      targetPort: 80
  selector:
    name: mykubapp
  type: LoadBalancer
```

Cluster with extended grace period for shutting down container: k8s-deployment-myapi-grace.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mydeployment
spec:
  replicas: 2
  selector:
      matchLabels:
        name: mykubapp
  template:
    metadata:
      labels:
        name: mykubapp
    spec:
      terminationGracePeriodSeconds: 60
      containers:
        - name: myapi
          # image with UseShutdownTimeout 30s 
          image: juniormayhe/myapi:3
          ports:
            - containerPort: 80          
---
apiVersion: v1
kind: Service
metadata:
    name: mykubapp
spec:
  ports:  
    - protocol: TCP
      port: 8080
      targetPort: 80
  selector:
    name: mykubapp
  type: LoadBalancer
```

### Containerized API
```csharp
using System;
using System.Diagnostics;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace MyAPI
{
    public class Startup
    {
        private State state = State.Running;
        private static int total = 0;
 
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }
 
        public IConfiguration Configuration { get; }
 
        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddControllers();
        }
 
        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env, IHostApplicationLifetime hostApplicationLifetime)
        {
            Log($"Application starting. Process ID: {Process.GetCurrentProcess().Id}");
 
            // Triggered when the application host is performing a graceful shutdown. Requests may still be in flight. Shutdown will block until this event completes.
            hostApplicationLifetime.ApplicationStopping.Register(ApplicationRequestsIncomingAfterStopRequest);
 
            // Triggered when the application host is performing a graceful shutdown. All requests should be complete at this point. Shutdown will block until this event completes.
            hostApplicationLifetime.ApplicationStopped.Register(ApplicationRequestsAreCompleted);
 
            app.UseHttpsRedirection();
 
            app.Run(async (context) =>
            {
                var message = $"Host: {Environment.MachineName}, State: {state}";
 
                //if (!context.Request.Path.Value.Contains("/favicon.ico"))
                Interlocked.Increment(ref total);
                Log($"Incoming request {total} at {context.Request.Path}, {message}");
 
                await DoSomeWork(context);
 
                await context.Response.WriteAsync(message);
            });
        }
 
        private async Task DoSomeWork(HttpContext context)
        {
            if (context.Request.Path.Value.Contains("slow"))
            {
                await SleepAndPrintForSeconds(2);
            }
            else
            {
                await Task.Delay(500);
            }
        }
 
        private void ApplicationRequestsIncomingAfterStopRequest()
        {
            state = State.AfterSigterm;
 
            // we enter here when SIGTERM or SIGINT has been sent by Kubernetes
            Log("# this app is stopping. wating 20 seconds for in-flight requests");

            // the default shutdown timeout is 5 seconds for netcore app
            // the default termination grace period is 30 seconds for kubernetes
            // kubernetes loadbalancer may take around 10 seconds to get updated
            // we can sleep the app for 20 seconds to respond requests giving loadbalancer enough time
            Thread.Sleep(20000);
        }
 
        private void ApplicationRequestsAreCompleted()
        {
            // in a graceful shutdown this is shown. 
            // otherwise operation canceled triggers in Main, 
            // and all requests may have completed even after host is canceled
            Log($"# this app has stopped. all requests completed. latest {total}");
        }
 
        private void Log(string msg) => Console.WriteLine($"{DateTime.UtcNow}: {msg}");
 
        private async Task SleepAndPrintForSeconds(int seconds)
        {
            do
            {
                Log($"Sleeping ({seconds} seconds left)");
                await Task.Delay(1000);
            } while (--seconds > 0);
        }
    }
}
```

### Dockerfile
```
#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.
 
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443
 
FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
WORKDIR /src
COPY ["MyAPI.csproj", ""]
RUN dotnet restore "./MyAPI.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "MyAPI.csproj" -c Release -o /app/build
 
FROM build AS publish
RUN dotnet publish "MyAPI.csproj" -c Release -o /app/publish
 
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
# MANDATORY if node app or other PID 1 app cannot be interrupted by SIGINT
# STOPSIGNAL SIGINT 
ENTRYPOINT ["dotnet", "MyAPI.dll"]
```

## Results of load test
After creating cluster the desired scenario:
```
kubectl apply -f k8s-deployment-myapi.yaml
```

To understand if all requests were responded by netcore app while scale down happens, we started requests in Postman and Bombardier.

Then we scaled down the deployment for each scenario

```
kubectl scale --replicas=1 deployment mydeployment
```

At this moment, Kubernetes sends a SIGTERM to one of the containers, which passes the signal to the netcore application, which by its turn triggers the ApplicationStopping to wait the number of seconds defined in Thread.Sleep, if implemented. After the SIGTERM, remaining requests were processed. 

In the following evidence, the Thread.Sleep was set to 25 seconds, and an operation canceled shows up indicating the process was ended. 

```
07/20/2020 13:42:15: Incoming request at /, Host: mydeployment-7ccbdff885-mkf54, State: Running
07/20/2020 13:42:15: # this app is stopping. there may be incoming requests left
07/20/2020 13:42:15: Incoming request at /, Host: mydeployment-7ccbdff885-mkf54, State: AfterSigterm
...
07/20/2020 13:42:40: Incoming request at /, Host: mydeployment-7ccbdff885-mkf54, State: AfterSigterm
info: Microsoft.Hosting.Lifetime[0]
      Application is shutting down...
07/20/2020 13:42:40: Incoming request at /, Host: mydeployment-7ccbdff885-mkf54, State: AfterSigterm
...
07/20/2020 13:42:41: Incoming request at /, Host: mydeployment-7ccbdff885-mkf54, State: AfterSigterm
07/20/2020 13:42:41: # app was cancelled
```

Although there was a cancellation, all remaining requests were responded correctly, as follows:

200 requested by Postman, netcore app responded all with status code 200 OK

1000 requested by Bombardier, netcore app responded all with status code 200 OK

```
Bombarding http://localhost:8080 with 1000 request(s) using 10 connection(s)
 1000 / 1000 [===================================================================================================================================================] 100.00% 95/s 10s
Done!
Statistics        Avg      Stdev        Max
  Reqs/sec        96.96      58.06     307.48
  Latency      102.91ms     5.13ms   173.69ms
  HTTP codes:
    1xx - 0, 2xx - 1000, 3xx - 0, 4xx - 0, 5xx - 0
    others - 0
  Throughput:    21.19KB/s
```

We also did the same test for the scenario where an image has no Thread.Sleep implemented. All requests were again responded correctly. 

In all scenarios, we never see the message from ApplicationStopped event because the netcore app process gets canceled after all requests have been fulfilled, which seems to be the normal behavior for cancellation.

## Conclusions
TL;DR

After a scale down in the Kubernetes cluster, all in-flight or pending requests are fulfilled by netcore application after receiving a termination signal. Since the Routing Service might need some time to dispatch its internal events (around 45 seconds) and to avoid changing the application, we could make use of terminationGracePeriodSeconds

The netcore [IWebHostBuilder.UseShutdownTimeout](https://docs.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.hosting.hostingabstractionswebhostbuilderextensions.useshutdowntimeout?view=aspnetcore-3.1) has no effect because the higher object in Kubernetes has priority on shutdown policy, so the app cannot extend its own grace period because it must obey to the Kubernetes deployment specification, defined in Kubernetes declarative yaml.

There would be an edge case where the netcore application receives a SIGTERM (shutdown request) but the load balancer did not get updated yet, so the pod container keeps receiving in-flight requests.

We were unable to reproduce this update slowness in the load balancer, because all requests were responded were all answered within the expected time status code 200 OK after the scale down.

To get around this possible edge case with Kubernetes load balancer update slowness, there is a [suggestion](https://blog.markvincze.com/graceful-termination-in-kubernetes-with-asp-net-core/) to add a Thread.Sleep in ApplicationStopping event to give the load balancer time to update itself while the application responds to requests. The ApplicationStopping is a host lifetime that can be defined on netcore application startup.

We tested the scale down with two images, one with and another without this suspension in the host lifetime thread and the requests were all satisfied. We even create a netcore application image that responds in 500ms response time which is the average response time of Routing Service and all requests were again responded correctly after the scale down.

Kubernetes gives a default of [30 seconds](https://kubernetes.io/docs/concepts/workloads/pods/pod/#termination-of-pods) for the container to shut down. Within 30 seconds, in around 10 seconds it updates the Load Balancer. We could not find if 10 seconds is related to a health check interval done with a [default readiness probe interval](https://github.com/kubernetes/kubernetes/blob/master/pkg/apis/core/v1/defaults_test.go#L70), set by periodSeconds.

If the application has some final processing to do, we extend the time in ApplicationStopping event to deal with pending tasks. Or we can avoid this implementation and extend the time via Kubernetes declarative yaml with the setting terminationGracePeriodSeconds: 60 so the application has more time to do some final processing within this time limit.

## References

- https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- https://github.com/juniormayhe/Scripts/tree/master/docker
- https://github.com/juniormayhe/Scripts/tree/master/kubernetes
- https://docs.microsoft.com/en-us/aspnet/core/fundamentals/middleware/?view=aspnetcore-3.1
- https://linux.die.net/Bash-Beginners-Guide/sect_12_01.html
- https://docs.microsoft.com/en-us/dotnet/architecture/containerized-lifecycle/design-develop-containerized-apps/build-aspnet-core-applications-linux-containers-aks-kubernetes
