# 0001-Keycloak
This document provides guidance on setting up Keycloak in a Kubernetes cluster. It serves as a basic tutorial for developers to install and configure Keycloak on a Kubernetes environment running on a local machine. 


# Objective

In a microservices architecture, it's essential to manage the authentication and authorization functions of our applications, allowing users to authenticate and verify their identity when clients interact with the microservice APIs. We need the capability to assign roles and permissions to users for API access. Based on my analysis, one of the best open-source solutions for managing Identity and Access Management (IAM) is Keycloak, which can be effectively utilized in our microservices setup.

I have added some of the required in our application

1. **Single Sign-On (SSO)**: Keycloak supports SSO, allowing users to log in once and gain access to multiple applications. This reduces the need for repeated authentication, enhancing user experience and productivity.
2. **User Federation**: Keycloak can connect to existing user directories like LDAP and Active Directory, allowing seamless integration with existing user bases without needing to migrate users.
3. **Identity Brokering and Social Login**: It enables integration with third-party identity providers and supports social login options like Google, Facebook, Twitter, and more, providing users with flexible login options.
4. **Centralized Management**: It provides a centralized place to manage users, roles, and permissions, simplifying the administration of user access across different applications.
5. **Standard Protocols**: Keycloak supports standard protocols like OAuth2, OpenID Connect, and SAML, ensuring interoperability with a wide range of applications and services.
6. **Security Features**: Keycloak offers robust security features, including multi-factor authentication (MFA), support for password policies, brute force attack protection, and more.
7. **Extensibility**: The platform is highly customizable, allowing the integration of custom extensions to meet specific requirements.
8. **Delegated Administration**: It allows the delegation of administration tasks to different levels of administrators, supporting hierarchical and distributed management.
9. **User Self-Service**: It offers self-service account management features, enabling users to update their profiles, change passwords, and manage their own accounts.
10. **Community and Enterprise Support**: As an open-source solution, Keycloak benefits from a large community of users and developers. Additionally, Red Hat offers enterprise support through Red Hat SSO for organizations needing commercial support and additional features.
11. **Integration with Applications**: Keycloak provides adapters for a variety of platforms and frameworks (Java, Node.js, Spring Boot, etc.), making it easier to integrate authentication and authorization into your applications.

## Setup local environment
I use Docker containers to set up work environments for multiple applications([Setup Environment](https://dev.to/binoy_59380e698d318/setup-linux-box-on-local-with-docker-container-3k8)). This approach ensures fully isolated and maintainable environments for application development, allowing us to easily start and terminate these environments. Below is the Docker command to create the environment.
```shell
  docker run -it --name test-envornment-box -v ${HOME}:/root/ -v ${PWD}:/work -w /work --net host developerhelperhub/kub-terr-work-env-box sh
```
The container contains Docker, Kubectl, Helm, Terraform, Kind, Git

## Setup Jenkins on Kubernetes Cluster 

I have created all the Terraform scripts, which are available in the GitHub repository. You can download and set up Jenkins on a Kubernetes cluster, which runs locally in a Docker container.

**Clone the repository** onto your local Linux machine to get started.
```shell
git clone https://github.com/developerhelperhub/kuberentes-help.git
cd kuberentes-help/kubenretes/tutorials/sections/0011/terraform
```

**Set up the Kubernetes cluster** in a Docker container using Kind, naming the cluster “test-cluster-control-plane” This cluster supports ingress and exposes ports 80 and 443 to allow access to services from outside the cluster. Following resources also created along with this cluster creation


- Install Nginx ingress controller on Kubernetes cluster to manage the external access to services in a Kubernetes cluster. It acts as an entry point for your Kubernetes applications, routing external HTTP and HTTPS traffic to the appropriate services within the cluster.
- Create a namespace which called “microservices”

Cluster create terraform script available under terraform folder
```shell
cd kind
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

# Setup Keycloak

Add the Keycloak Helm Repository: To begin, you need to add the Keycloak Helm repository to your Helm client:
```shell
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```
The following command can be used to verify the app version and chart version of the services installed in the cluster:
```shell
helm search repo bitnami/keycloak
```
In this example, I am installing the cart version is “22.2.3” and App Version is “25.0.5”
```shell
bitnami/keycloak        22.2.3               25.0.5             Keycloak is a high performance Java-based ident...
```
Create a Helm values YAML file named `helm-value.yaml`, which will be used to configure the Keycloak service. This configuration file will be utilized by Helm to install the service in the cluster.
```yaml
auth:
  adminUser: "admin"
  adminPassword: "password123"
persistence:
  enabled: true 
persistence.size: "8Gi"
```
The following Helm command is used to install Keycloak in the cluster. It creates the necessary resources in the cluster and installs all resources within this namespace.
```shell
helm install keycloak -f helm-value.yaml bitnami/keycloak --namespace microservices
```
Helm chart values: https://github.com/bitnami/charts/blob/main/bitnami/keycloak/values.yaml

We can verify that all resources have been installed in the "microservices" namespace. The Keycloak service UI is running on port 80.
```shell
kubectl get -n microservices all

pod/keycloak-0              0/1     Running   0          3m56s
pod/keycloak-postgresql-0   1/1     Running   0          3m56s

NAME                             TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/keycloak                 ClusterIP   10.96.126.12   <none>        80/TCP     3m56s
service/keycloak-headless        ClusterIP   None           <none>        8080/TCP   3m56s
service/keycloak-postgresql      ClusterIP   10.96.86.112   <none>        5432/TCP   3m56s
service/keycloak-postgresql-hl   ClusterIP   None           <none>        5432/TCP   3m56s

NAME                                   READY   AGE
statefulset.apps/keycloak              0/1     3m56s
statefulset.apps/keycloak-postgresql   1/1     3m56s
```
We need to create an Ingress resource to route requests to the Keycloak service. Add the following configuration to the `ingress-resource.yaml` file.
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: keycloak-ingress
  namespace: microservices
spec:
  ingressClassName: nginx
  rules:
    - host: keycloak.myapp.com
      http:
        paths:
          - path: /
            pathType: ImplementationSpecific
            backend:
              service:
                name: keycloak
                port:
                  number: 80
```
Execute the following command to apply the ingress in the cluster
```shell
kubectl apply -f ingress-resource.yaml
```
Verify the IP address is set:
```shell
kubectl -n microservices get ingress

NAME               CLASS   HOSTS                ADDRESS     PORTS   AGE
keycloak-ingress   nginx   keycloak.myapp.com   localhost   80      8m3s
```
Add our domain to the bottom of the `/etc/hosts` file on your local machine. This configuration should not be inside our working Linux box “test-envornment-box”; it should be applied to your personal machine's `/etc/hosts` file. 
(you will need administrator access):
```shell
127.0.0.1 keycloak.myapp.com
```
We can open the keycloak UI in the browser “http://keycloak.myapp.com/”


![](https://paper-attachments.dropboxusercontent.com/s_B19EEAEB115D0C35E36E6763FBF9673A27FBEA2FC883C8357D7AD631EA5ABE5E_1726162814170_image.png)


**Note:** This Helm configuration is not suitable for a production environment; we need to adjust the appropriate values to align with our production workload requirements.

