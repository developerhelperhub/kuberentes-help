# 0012-High Availability and Scalability deployment Microservices on Kubernetes cluster 
This section outlines how to deploy microservices in a Kubernetes cluster to ensure high availability and scalability for our applications. We will explore the key configuration considerations for deploying applications and services within the cluster.

**Explain the following Kubernetes**
- Configure Pod Disruption Budget (PDB)
- Configure Horizontal Pod Autoscaler (HPA)
- Configure Rolling Update
- Configure Pod Distribution Policy
- Configure Canary Deployment Strategy
- Configure Probe Configuration of Health API
# Objective

In a microservice architecture, certain applications demand maximum high availability and scalability. Based on my experience, we need to address the following challenges:

- How to efficiently scale services up or down based on request load.
- How to prevent downtime during new releases.
- How to minimize or avoid user impact if issues arise in a new release.
- How to deploy services across multiple availability zones or regions to ensure high availability.
![](https://paper-attachments.dropboxusercontent.com/s_9ACF0DEAB1882FCFDDBB270D889FE811EA1E597909B1A2EB13AEB3AF68D4E2F6_1726857208415_Microservice-Microservices+Deployments.drawio+2.png)

# Setup local environment
I use docker containers to set up work environments for multiple applications([Setup Environment](https://dev.to/binoy_59380e698d318/setup-linux-box-on-local-with-docker-container-3k8)). This approach ensures fully isolated and maintainable environments for application development, allowing us to easily start and terminate these environments. Below is the Docker command to create the environment.
```shell
docker run -it --name test-envornment-box -v ${HOME}:/root/ -v ${PWD}:/work -w /work --net host developerhelperhub/kub-terr-work-env-box sh
```
## Setup resources on Kubernetes

I have created all the Terraform scripts, which are available in the GitHub repository. You can download them to set up resources on a Kubernetes cluster running locally in a Docker container. The following resources are installed:

**Set up the Kubernetes cluster** in a Docker container using Kind, naming the cluster “microservices-development-cluster-config” This cluster supports ingress and exposes ports 80 and 443 to allow access to services from outside the cluster. Following resources also created along with this cluster creation

- Install Nginx ingress controller on Kubernetes cluster to manage the external access to services in a Kubernetes cluster. It acts as an entry point for your Kubernetes applications, routing external HTTP and HTTPS traffic to the appropriate services within the cluster.
- Create a namespace which called “microservices”
- Install Prometheus and Grafana to monitor the resources and services

**Clone the repository** onto your local Linux machine to get started.
```shell
git clone https://github.com/developerhelperhub/spring-boot-microservices-deployment-kube.git
```
Cluster create terraform script available under terraform folder
```shell
cd terraform

terraform init #Install the required providers to set up the necessary resources.
terraform plan -var="kind_cluster_name=microservices-development-cluster" #Verify the resources that will be installed on the system.
terraform apply -var="kind_cluster_name=microservices-development-cluster" #Install resources on the system
```
Following command verify the cluster and respective services
```shell
#Verifying the cluster and node
kubectl cluster-info
kubectl get nodes -o wide

#Verifying the ingress controll resources
kubectl get -n ingress-nginx pod

#Verifying the namespace
kubectl get namespace
```
Login Grafana "[http://grafana.devops.com](http://grafana.devops.com/)" and it username and password are "admin" and "MyPassword1222@"

# Spring Boot Microservice Applications

In this example, I have developed microservices using the Spring Boot framework, and the application is running on a JDK 22 container image. These images are being deployed in Kubernetes containers. To enable communication between multiple microservices and clients, I am utilizing an NGINX Ingress controller to route requests to each microservice. The Spring Boot projects are organized in the "spring-boot-microservices" folder, which contains three Maven projects. These projects follow best practices for managing dependencies, versions, plugins, and builds in Maven, while also configuring services for different environments, such as development and production.

**"microservice-ecommerce-system"**: This is a Maven POM module that contains the shared configurations required across all microservices in the project.

- **Java Configuration**
- **Dependency Management**: Ensures consistent versions of dependencies across all microservices.
- **Plugin Management**: Provides a unified plugin configuration for all microservices, including:
    - **Production Image Build**: Configured with GraalVM and Ahead-of-Time (AOT) compilation, creating a binary named "app-native-binary."
    - **Development Build**: All services use the same Java build name, "app.jar," simplifying Dockerfile configuration.
    - **Build Info Generation**: Includes build information in the "/actuator/info" endpoint.

**"order-service"**: A Maven project exposing API endpoints.

- **Functional Endpoint**:
    - `/orders` - Returns a list of orders.
- **Actuator Endpoints**:
    - `/actuator/info` - Displays build info, Java SDK version, etc.
    - `/actuator/health` - Indicates if the service is up or down.
    - `/actuator/health/liveness` - Monitors whether the service is responding slowly, allowing Kubernetes to restart the pod if needed.
    - `/actuator/health/readiness` - Shows if the service is ready to accept requests.
    - `/actuator/health/startup` - Confirms if the service has fully started. Used to test startup times to avoid premature Kubernetes restarts. In this case, the service takes 2 seconds to start.
- **Port Configurations for Different Environments**:
    - Local: `8082`
    - Dev/Prod: `8080`
- **Log Configuration for Different Environments**:
    - Local: `TRACE`
    - Dev: `DEBUG`
    - Prod: `INFO`

**"item-service"**: Another Maven project exposing API endpoints.

- **Functional Endpoint**:
    - `/items` - Returns a list of items.
- **Actuator Endpoints**:
    - `/actuator/info` - Displays build info, Java SDK version, etc.
    - `/actuator/health` - Indicates if the service is up or down.
    - `/actuator/health/liveness` - Monitors whether the service is responding slowly, allowing Kubernetes to restart the pod if necessary.
    - `/actuator/health/readiness` - Shows if the service is ready to accept requests.
- **Port Configurations for Different Environments**:
    - Local: `8081`
    - Dev/Prod: `8080`
- **Log Configuration for Different Environments**:
    - Local: `TRACE`
    - Dev: `DEBUG`
    - Prod: `INFO`
# Kubernetes Deployment Strategy 

In this section, I will explain the complete configuration and deployment strategy specifically for the **order-service**. The configuration is the same for the **item-service**, with the only difference being the varying values.
I have added different deployment strategy to achieve the maximum availability and scalability of the service as per understanding.

## Configure Pod Disruption Budget (PDB)

A **Pod Disruption Budget (PDB)** ensures that a minimum number of pods are available during voluntary disruptions (such as a rolling update or a node drain). This helps ensure that your application remains available during restarts.

depolyment\dev\kube-pod-disruption-budget.yaml
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: mes-order-service-pdb
spec:
  minAvailable: 2  # Ensure at least 2 pods are always running
  selector:
    matchLabels:
      app: mes-order-service
```

This configuration ensures that at least 2 pods of your application are always running, even during restarts or disruptions.

## Configure Horizontal Pod Autoscaler (HPA)

Automatically **scales the number of pods** in a deployment based on observed metrics such as CPU usage, memory usage, or custom metrics like request rates.

Used to **adjust the number of running pods dynamically** based on real-time traffic and resource usage, ensuring that your application scales out when load increases and scales down when load decreases.

depolyment\dev\kube-horizontal-pod-autoscaler.yaml
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: mes-order-service-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: mes-order-service
  minReplicas: 4
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
```
## Configure Rolling Update

**Purpose**: Controls **how** pods are updated during a deployment or upgrade. Ensures that the new version of an application is rolled out without downtime by replacing old pods with new ones in a gradual manner.

**Use Case**: This is used when **updating an application** to a new version, allowing the system to introduce changes without disrupting users.

**Mechanism**: During a rolling update, Kubernetes replaces old pods with new ones gradually. This ensures that the application remains available while updating.

- **maxUnavailable**: The maximum number of pods that can be unavailable during the update.
- **maxSurge**: The maximum number of additional pods that can be created above the desired number during the update.

depolyment\dev\kube-deployment.yaml
```yaml
spec:
  replicas: 3 # Number of pods to run
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2  # Max number of extra pods created during the update
      maxUnavailable: 1 # Max number of unavailable pods during the update
```
## Configure Pod Distribution Policy

**Purpose**: Controls **where** pods are scheduled across the nodes in a Kubernetes cluster. It ensures even distribution of pods across different failure zones, nodes, or other topology segments (e.g., regions, availability zones).

**Use Case**: This policy is used for **high availability** and fault tolerance, ensuring that a failure in one node or zone does not impact all replicas of an application.

**Mechanism**: Pod distribution is influenced by **affinity rules**, **topology spread constraints**, and **taints and tolerations**.

- **Node Affinity**: Ensures that pods are only placed on specific nodes that meet certain criteria.
- **Pod Affinity/Anti-Affinity**: Ensures that specific pods are placed together (affinity) or apart (anti-affinity) from other pods.
- **Topology Spread Constraints**: Ensures that pods are spread evenly across different zones or failure domains.

depolyment\dev\kube-deployment.yaml
```yaml
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
            - key: app
              operator: In
              values:
                - mes-order-service
        topologyKey: "topology.kubernetes.io/zone"
```
## Kubernetes Probe Configuration

These probes help Kubernetes decide whether to start, stop, or restart containers based on their health status. There are three main types of probes:

**Liveness Probe**:
This probe checks if a container is still alive. If a liveness probe fails, Kubernetes will kill the container and restart it according to the pod's restart policy. It’s used to detect situations where a container is stuck and cannot recover.

**Readiness Probe**:
The readiness probe determines if a container is ready to serve traffic. If this probe fails, the container will be removed from the pool of endpoints that receive traffic, without being restarted. This ensures that only healthy containers are used to serve requests.

**Startup Probe**:
This probe is used to determine if a container has started successfully. It’s especially useful for containers that take a long time to initialize. If the startup probe fails, Kubernetes will restart the container. If a startup probe is configured, the liveness and readiness probes will be disabled until the startup probe succeeds.

depolyment\dev\kube-deployment.yaml
```yaml
livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 10
readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5
startupProbe:
  httpGet:
    path: /actuator/health/startup
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
```
**Note**: Spring boot default not provide the startup endpoint in the actuator dependency, I have created following component and configuration to setup the startup endpoint

Create the startup health indicator
```java
@Component
public class StartupHealthIndicator implements HealthIndicator {
    @Setter
    private boolean startupComplete = false;
    @Override
    public Health health() {
        if (this.startupComplete) {
            return Health.up().withDetail("startup", "Complete").build();
        } else {
            return Health.down().withDetail("startup", "In Progress").build();
        }
    }
}
```
Configure the health indicator in the startup application to enable the startup complete = true
```java
@Slf4j
@SpringBootApplication
public class OrderServiceApplication implements ApplicationRunner {
    @Autowired
    private StartupHealthIndicator startupProbeHealthIndicator;
    public static void main(String[] args) {
        SpringApplication.run(OrderServiceApplication.class, args);
    }
    @Override
    public void run(ApplicationArguments args) throws Exception {
        log.info("Application loading information.....");
        // We can add logic to load initial code after application start successfully.
        // Startup health endpoint help Kubernetes avoid to kill the application if the application loading process is taking longer
        Thread.sleep(20000);
        this.startupProbeHealthIndicator.setStartupComplete(true);
        log.info("Application loading successfully!");
    }
}
```
## Configure Canary Deployment Strategy
In Kubernetes, a **canary deployment** is a strategy that allows you to release a new version of an application to a small subset of users before rolling it out to the entire environment. This allows you to test the new version in production with minimal risk. The canary strategy can be implemented using **Kubernetes Ingress** by splitting traffic between the stable version of the application and the new version (canary).

**Stable version deployment:** This is stable deployed version on production
depolyment\dev\kube-deployment.yaml 
```yaml
template:
  metadata:
    labels:
      app: mes-order-service
      type: service
      env: dev
      version: 1.0.0.1    #stable version
```
**Canary version deployment:** This is the new version is deploying on production
depolyment\dev\kube-deployment.yaml 
```yaml
template:
  metadata:
    labels:
      app: mes-order-service
      type: service
      env: dev
      version: 1.0.0.2    #canary version
```
**Configure the canary in ingress resource**
ingress-resource.yaml
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: emc-app-ingress
  namespace: microservices
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "25"
```
## Routing request to microservices in the Ingress Resource

We need to configure the routing in the ingress resource to direct requests to the appropriate microservices.
ingress-resource.yaml
```yaml
spec:
  ingressClassName: nginx
  rules:
    - host: mes.app.com
      http:
        paths:
          - path: /order-service(/|$)(.*)
            pathType: ImplementationSpecific
            backend:
              service:
                name: mes-order-service
                port:
                  number: 8080
          - path: /item-service(/|$)(.*)
            pathType: ImplementationSpecific
            backend:
              service:
                name: mes-item-service
                port:
                  number: 8080
```
## Deploy Order Service

Following command to deploy the pods of order service
```shell
kubectl -n microservices -f deployment/dev/kube-deployment.yaml apply
kubectl -n microservices get pod -l app=mes-order-service
kubectl -n microservices describe pod/mes-order-service-64c86c5f56-c5cpd
kubectl -n microservices logs pod/mes-order-service-64c86c5f56-c5cpd
```
Following command is create the service of order service
```shell
kubectl -n microservices -f deployment/dev/kube-service.yaml apply
kubectl -n microservices get svc
```
Following command configure the HPS and PDB
```shell
kubectl -n microservices -f deployment/dev/kube-horizontal-pod-autoscaler.yaml apply
kubectl -n microservices get hpa
kubectl -n microservices -f deployment/dev/kube-pod-disruption-budget.yaml apply
kubectl -n microservices get pdb
```
**### Apply ingress resource of microservices**
Following command to create the ingress resource
```shell
kubectl -n microservices -f ../../ingress-resource.yaml apply
```
Following command helps to test the endpoint order API. The postman collections is available in git repo as well
```shell
curl http://mes.app.com/order-service/orders
```

## Reference 
* https://github.com/developerhelperhub/spring-boot-microservices-deployment-kube
* https://www.baeldung.com/spring-boot-actuators
* https://docs.spring.io/spring-boot/reference/actuator/endpoints.html#actuator.endpoints.kubernetes-probes
* https://docs.spring.io/spring-boot/reference/actuator/endpoints.html#actuator.endpoints.kubernetes-probes.lifecycle
* https://medium.com/@nanayakkaraoffice/spring-boot-3-graalvm-hint-api-28e0e169d227


