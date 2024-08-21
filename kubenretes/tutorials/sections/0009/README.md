# 0009-JFrog
This document provides guidance on setting up JFrog Artifactory in a Kubernetes cluster. It serves as a basic tutorial for developers to install and configure JFrog on a Kubernetes environment running on a local machine.

## Setup local environment to build DevOps resources

I use Docker containers to set up work environments for multiple applications([Setup Environment](https://dev.to/binoy_59380e698d318/setup-linux-box-on-local-with-docker-container-3k8)). This approach ensures fully isolated and maintainable environments for application development, allowing us to easily start and terminate these environments. Below is the Docker command to create the environment.
```shell
docker run -it --name test-jfrog-envornment-box -v ${HOME}/root/ -v ${PWD}/work -w /work --net host developerhelperhub/kub-terr-work-env-box sh
```

The container contains Docker, Kubectl, Helm, Terraform, Kind, Git

## Setup Jenkins on Kubernetes Cluster 

I have created all the Terraform scripts, which are available in the GitHub repository. You can download and set up Jenkins on a Kubernetes cluster, which runs locally in a Docker container.

**Clone the repository** onto your local Linux machine to get started.
```shell
git clone https://github.com/developerhelperhub/kuberentes-help.git
cd kuberentes-help/kubenretes/tutorials/sections/0009/
```

**Set up the Kubernetes cluster** in a Docker container using Kind, naming the cluster “devops-jfrog-cluster-control-plane” This cluster supports ingress and exposes ports 80 and 443 to allow access to services from outside the cluster.

Cluster create terraform script available under kind folder
```shell
cd kind
terraform init #Install the required providers to set up the necessary resources.
terraform plan #Verify the resources that will be installed on the system.
terraform apply #Install resources on the system
```
Following command verify the cluster
```shell
kubectl cluster-info
kubectl get nodes -o wide
```

**Setup Nginx ingress controller on Kubernetes cluster**
The NGINX Ingress Controller to manage the external access to services in a Kubernetes cluster. It acts as an entry point for your Kubernetes applications, routing external HTTP and HTTPS traffic to the appropriate services within the cluster.

Following command install the ingress controller on cluster

Ingress create script available under “ingress” folder
```shell
cd ingress
kubectl apply -f ingress-nginx.yaml
```

Following command verify the nginx ingress controller
```shell
kubectl get -n ingress-nginx pod
```

Output
```shell
NAME                                       READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-5mt2k       0/1     Completed   0          53s
ingress-nginx-admission-patch-w2rlk        0/1     Completed   0          53s
ingress-nginx-controller-d45d995d4-gl65h   1/1     Running     0          53s
```

# Setup JFrog Artifactory OSS (Open Source)

Add the JFrog Artifactory OSS Community Helm Repository: To begin, you need to add the JFrog Artifactory OSS community Helm repository to your Helm client:

Note: JFrog create scripts available under “jfrog” folder
```shell
helm repo add jfrog https://charts.jfrog.io
helm repo update
```
The following command can be used to verify the app version and chart version of the services installed in the cluster:
```shell
helm search repo  artifactory-oss
```

In this example, I am installing the cart version is “107.90.8” and App Version is “7.90.8”
```shell
NAME                         CHART VERSION        APP VERSION        DESCRIPTION
jfrog/artifactory-oss        107.90.8             7.90.8             JFrog Artifactory OSS
```
Create a Helm values YAML file named `helm-value.yaml`, which will be used to configure the JFrog Artifactory OSS service. This configuration file will be utilized by Helm to install the service in the cluster.
```yaml
artifactory:
    postgresql:
    postgresqlPassword: postgres_password
    nginx:
    enabled: false
    ingress:
    enabled: false
```

In the above configuration, I have configured the following points:

- Helm is using the default PostgreSQL database, where I specified the database password.
- NGINX and Ingress resources are disabled.

The following Helm command is used to install Artifactory in the cluster. It creates the necessary resources in the cluster, including a namespace called "artifactory-oss," and installs all resources within this namespace.
```shell
helm install artifactory-oss -f helm-value.yaml jfrog/artifactory-oss --namespace artifactory-oss --create-namespace
```
Helm chart values: https://github.com/jfrog/charts/blob/master/stable/artifactory-oss/values.yaml

We can verify that all resources have been installed in the "artifactory-oss" namespace. The Artifactory service UI is running on port 8082, while Artifactory itself is operating on port 8081.
```shell
kubectl get -n artifactory-oss all

NAME                               READY   STATUS    RESTARTS   AGE
pod/artifactory-oss-0              0/7     Running   0          3m19s
pod/artifactory-oss-postgresql-0   1/1     Running   0          3m19s

NAME                                          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
service/artifactory-oss                       ClusterIP   10.96.170.63   <none>        8082/TCP,8025/TCP,8081/TCP   3m19s
service/artifactory-oss-postgresql            ClusterIP   10.96.95.36    <none>        5432/TCP                     3m19s
service/artifactory-oss-postgresql-headless   ClusterIP   None           <none>        5432/TCP                     3m19s

NAME                                          READY   AGE
statefulset.apps/artifactory-oss              0/1     3m19s
statefulset.apps/artifactory-oss-postgresql   1/1     3m19s
```

We need to create an Ingress resource to route requests to the Artifactory service. Add the following configuration to the `ingress-resource.yaml` file.
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
    name: jfrog-ingress
    namespace: artifactory-oss
    annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
spec:
    ingressClassName: nginx
    rules:
    - host: jfrog.artifactory.devops.myapp.com
        http:
        paths:
            - path: /
            pathType: ImplementationSpecific
            backend:
                service:
                name: artifactory-oss
                port:
                    number: 8082
```
We need to configure `proxy-body-size=0`. This setting instructs the Ingress not to impose a limit on the file size when uploading files to Artifactory.

Execute the following command to apply the ingress in the cluster
```shell
kubectl apply -f ingress-resource.yaml
```

Verify the IP address is set:
```shell
kubectl -n artifactory-oss get ingress

NAME            CLASS   HOSTS                                ADDRESS     PORTS   AGE
jfrog-ingress   nginx   jfrog.artifactory.devops.myapp.com   localhost   80      2m53s
```

Add our domain to the bottom of the `/etc/hosts` file on your local machine. This configuration should not be inside our working Linux box “test-jfrog-envornment-box”; it should be applied to your personal machine's `/etc/hosts` file. 
(you will need administrator access):
```shell
127.0.0.1 jfrog.artifactory.devops.myapp.com
```

We can open the artifactory UI in the browser “http://jfrog.artifactory.devops.myapp.com/”

![](https://paper-attachments.dropboxusercontent.com/s_16C6592C2C29665804FB36AE73D0E050E2EF20D7F0373F598A755184EEBEA4CA_1724261798489_image.png)


You can log in using the default username "admin" and password "password." Upon your first login, Artifactory will prompt you to change the default password. Be sure to update the password, set the base URL to `http://jfrog.artifactory.devops.myapp.com` (the domain configured in the Artifactory Ingress resource), and skip any other initial configuration steps.

We can create the initial repositories configurations to push the dependencies and binary in the artifactory.

Navigate to “Artifactory → Artifacts → Manage Repositories → Create Repository” and create the following repositories:

- **Local**: This repository manages your application binaries. For example “my-app-snapshot”
- **Remote**: This repository stores all dependencies used in your application, which will be downloaded from central repositories and stored in repository. For example “my-app-central-snapshot”
- **Virtual**: This virtual repository provides a common endpoint that aggregates the “Local” and “Remote” repositories. This endpoint will be configured in your application. “my-app-virtual-snapshot”

I am using maven repository to maintain the repository. Following configuration we have to give “my-app-snapshot” local repository

![](https://paper-attachments.dropboxusercontent.com/s_16C6592C2C29665804FB36AE73D0E050E2EF20D7F0373F598A755184EEBEA4CA_1724263571034_image.png)


Following configuration we have to give “my-app-central-snapshot” local repository

![](https://paper-attachments.dropboxusercontent.com/s_16C6592C2C29665804FB36AE73D0E050E2EF20D7F0373F598A755184EEBEA4CA_1724263718776_image.png)


Following configuration we have to give “my-app-virtual-snapshot” local repository

![](https://paper-attachments.dropboxusercontent.com/s_16C6592C2C29665804FB36AE73D0E050E2EF20D7F0373F598A755184EEBEA4CA_1724263811830_image.png)

![](https://paper-attachments.dropboxusercontent.com/s_16C6592C2C29665804FB36AE73D0E050E2EF20D7F0373F598A755184EEBEA4CA_1724265686678_image.png)


Add the local and remote repositories to the virtual repository and select the local repository in the “Default Deployment Repository”. 

Once all the repositories are created, you can view them in the main section under “Artifactory → Artifacts.” The virtual URL `http://jfrog.artifactory.devops.myapp.com/artifactory/my-app-virtual-snapshot/` will be used for your Maven application.

![](https://paper-attachments.dropboxusercontent.com/s_16C6592C2C29665804FB36AE73D0E050E2EF20D7F0373F598A755184EEBEA4CA_1724263959111_image.png)


We need to configure the authentication details in the Maven settings configuration file “~/.m2/settings.xml” to enable your Maven application to authenticate with Artifactory. 
```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">
    <servers>
        <server>
            <id>my-app-virtual-snapshot</id>
            <username>admin</username>
            <password>Give your artifactory admin passoword</password>
        </server>
    </servers>
</settings>
```

Note: The admin user should not be used for UI and Artifactory access. Instead, create a custom user with appropriate permissions for reading and writing in Artifactory.

We have configure the maven repository and distribution management tags inside our maven application POM XML file
```xml
<distributionManagement>
    <repository>
        <uniqueVersion>false</uniqueVersion>
        <id>my-app-virtual-snapshot</id>
        <name>my-app-virtual-snapshot</name>
        <url>http://jfrog.artifactory.devops.myapp.com/artifactory/my-app-virtual-snapshot/</url>
        <layout>default</layout>
    </repository>
</distributionManagement>

<repositories>
    <repository>
        <id>my-app-virtual-snapshot</id>
        <name>my-app-virtual-snapshot</name>
        <url>http://jfrog.artifactory.devops.myapp.com/artifactory/my-app-virtual-snapshot/</url>
        <layout>default</layout>
    </repository>
</repositories>
```

The we can deploy the maven application with following command
```shell
mvn clean deploy
```
We can the following output of maven :

![](https://paper-attachments.dropboxusercontent.com/s_16C6592C2C29665804FB36AE73D0E050E2EF20D7F0373F598A755184EEBEA4CA_1724265863976_image.png)

Refernece Git Repo
* https://github.com/developerhelperhub/spring-boot-jfrog-artifact-app
* https://github.com/developerhelperhub/kuberentes-help/tree/main/kubenretes/tutorials/sections/0009
