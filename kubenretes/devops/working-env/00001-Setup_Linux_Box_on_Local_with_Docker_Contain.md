# 00001-Setup Linux Box on Local with Docker Container
This section explains how to set up a Linux environment within a Docker container on a local machine. When working on multiple projects locally, it's common to install and configure various tools and services, each potentially requiring different versions. Using Docker ensures that the setup for one project doesn't affect others, maintaining complete isolation between project environments and their respective tools and services. 

I've discovered setup tools that facilitate the quick configuration of local environments and onboarding of tools and services. This approach allows us to onboard team members swiftly in a software development context without spending time setting up the environment. By storing the Docker image in a container registry, other team members can easily use it to set up their local environments. 

In this software architecture setup, we are achieving one of the quality attributes related to 'Time to Market' efficiency.

![](https://paper-attachments.dropboxusercontent.com/s_9813B6C3D74885289A9505842B422FFB3821DD6D1857A8F30EB766535A11D04B_1722169132584_devops-Alpine+Linux+Box.drawio.png)

## Tools and Services

The following tools are used to achieve this level of quality

| Service / Tool | Design Consideration                                                                                                                                                                                                                                                                                                                             |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Docker         | Running services in a container allows for quick setup and teardown. We can store these Docker images in a container registry so that other team members can easily set them up in their local environments.<br><br>Docker Desktop helps us to facilitate container based development and testing for the developers.                            |
| Alpine Linux   | It is a small Linux environment that is simple and more secure, significantly reducing resource usage.                                                                                                                                                                                                                                           |
| Kind           | We can easily set up Kubernetes clusters in a local environment. In a microservices architecture, a key design consideration is ensuring that the application can scale quickly as needed, efficiently utilizing the maximum resources in the cluster. This approach helps reduce costs and allows for the rapid setup of multiple environments. |
| Terraform      | To set up resources in a Kubernetes cluster, we can use Terraform, which allows us to create scripts for automating infrastructure setup. This approach eliminates the need for manual configuration, improves development efficiency, and reduces the risk of setup failures when deploying multiple environments.                              |
| Kubectl        | The command-line tool for interacting with Kubernetes clusters. It allows you to deploy applications, manage cluster resources, and troubleshoot running applications.                                                                                                                                                                           |
| Helm           | Helm is a package manager for Kubernetes, allowing you to define, install, and manage Kubernetes applications using charts. Helm charts are pre-configured Kubernetes resources that can be easily deployed and versioned.                                                                                                                       |

## Install Docker Desktop 
****- Simplifies the setup of development environments.
- Ensures consistency across different development, testing, and production environments.
- Enables efficient use of resources by isolating applications in containers.

We need to install Docker Desktop on your local machine first.
([https://docs.docker.com/desktop/](https://docs.docker.com/desktop/)). 

We have to configure the host and port in the Docker Engine to access the our machine Docker Desktop inside of Linux Docker container. Following attributes need to add in the Docker Engine. 

“Setting → Docker Engine”
```json
"hosts": [
    "tcp://0.0.0.0:2375"
]
```

We are using the “2375” port to connect inside of Linux Docker container. Click on “Apply and Restart” the Docker Desktop. 

## Install / Run the Alpine Linux box 

I am using an amd64 system architecture to install all resources in my Linux environment. We run the Docker container with the `sh` command to access the container's shell, where we can install all relevant tools and services inside the Linux environment.

Create a folder before running this command, as any files or folders downloaded and created will be placed inside this directory. This local folder should be used before running 'sh' in the Linux environment.

```shell
docker run -it --name my-project-linux-box -v ${HOME}:/root/ -v ${PWD}:/work -w /work --net host amd64/alpine sh
```

- **Container Name**: my-project-linux-box
- **Volume Mounts**:
    - `${HOME}:/root/`: This mounts the user's home directory on the host machine to the `/root` directory in the container.
    - `${PWD}:/work`: This mounts the current working directory on the host machine to the `/work` directory in the container.
- **Working Directory**: The working directory inside the container is set to `/work`.
- **Network Mode**: The container uses the host's network stack (`--net host`). This configuration should only use for testing, This option sets the network mode to "host," which means the container will use the host's network stack directly, allowing it to access the host's network interfaces. One of the problem is “This can lead to port conflicts, especially in environments where multiple services or containers are running.”

**Configure Docker Host IP** 
Add the below configuration in the bash_profile
```shell
export DOCKER_HOST=tcp://localhost:2375
```

Execute the command for applying the changes of bash_profile
```shell
source ~/.bash_profile
```

**Install Docker Client in the Linux Box**
```shell
#To install Docker on Alpine Linux,
apk add --update docker openrc 

#To start the Docker daemon at boot
rc-update add docker boot

#To start the Docker daemon manually
service docker start

#ensure the status is running.
service docker status
```

Verify the Docker connection successfully connect
```shell
docker info

/work # docker info
Client:
    Version:    26.1.5
    Context:    default
    Debug Mode: false
    Plugins:
    buildx: Docker Buildx (Docker Inc.)
    Version:  v0.14.0
    Path:     /usr/libexec/docker/cli-plugins/docker-buildx
```

## Install the tools in the linux box

Following tools need to be installed in the linux box


1. Install “curl” : This helps us to download the files from internet inside cluster
```shell
apk add --no-cache curl
```
2. Install Kubectl v1.30.3 (amd64).
```shell
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.30.3/bin/linux/amd64/kubectl #download the file

chmod +x ./kubectl #change the permission

mv ./kubectl /usr/local/bin/kubectl  #move into bin folder

kubectl version #verify the installation
```
3. Install Kind v0.23.0 kind-linux-amd64
```shell
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64 # download file

chmod +x ./kind #change the permission

mv ./kind /usr/local/bin/kind #move into bin folder

kind version #verify the installation
```
4. Install Terraform 1.9.3 linux_amd64
```shell
wget https://releases.hashicorp.com/terraform/1.9.3/terraform_1.9.3_linux_amd64.zip -P /tmp/ #download file

unzip /tmp/terraform_1.9.3_linux_amd64.zip -d /usr/local/bin #uzip file and move into bin folder

terraform --version #verify the installation
```
5. Install Helm
```shell
curl -o /tmp/helm.tar.gz -LO https://get.helm.sh/helm-v3.10.1-linux-amd64.tar.gz #download file

tar -C /tmp/ -zxvf /tmp/helm.tar.gz #unzip tar file

mv /tmp/linux-amd64/helm /usr/local/bin/helm #move into bin folder

chmod +x /usr/local/bin/helm #change the file permission

helm version #verify installation
```
## Create Kubernetes cluster from Linux Box

I am using a Terraform script to create the Kubernetes cluster from the linux box inside Docker Desktop. This [script](https://github.com/developerhelperhub/kuberentes-help/tree/main/terraform/script/kind) and document available in the [Github](https://github.com/developerhelperhub/kuberentes-help/blob/main/terraform/tutorials/00001_-Setup%20Kubernetes%20Cluster%20on%20Docker%20with%20help%20of%20Kind.md). I have already explained in the Github repo how can create the Kubernetes Cluster with Kind and Terraform

**Create following script files**

1. Create the providers.tf
```shell
terraform {
    required_providers {
    kind = {
        source = "tehcyx/kind"
        version = "0.5.1"
    }
    }
}

provider "kind" {}
```
2. Create the main.tf
```shell
resource "kind_cluster" "default" {
    name            = "test-cluster"
    node_image      = "kindest/node:v1.30.2"
    wait_for_ready  = true

    kind_config {
        kind        = "Cluster"
        api_version = "kind.x-k8s.io/v1alpha4"

        node {
            role = "control-plane"
            extra_port_mappings {
                container_port = 80
                host_port      = 80
            }
        }
    }
}
```
3. Create the output.tf
```shell
output "kubeconfig" {
    value = kind_cluster.default.kubeconfig
}

output "endpoint" {
    value = kind_cluster.default.endpoint
}

output "client_key" {
    value = kind_cluster.default.client_key
}
```
4. Apply the Terraform script
```shell
terraform init #initial terraform 
terraform plan #verify the resources which installed in the environment
terraform apply #apply the terraform scripts
```
5. We verify the created Kubernetes cluster information using the following command:
```shell
kubectl cluster-info #verify the cluster information

kubectl get node -o wide #verify the node
```shell
## References
- [Install Kind](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [Installation Docker on Alpine](https://docs.genesys.com/Documentation/System/latest/DDG/InstallationofDockeronAlpineLinux)
- [Setup Kubernetes Cluster on Docker with help of Kind](https://github.com/developerhelperhub/kuberentes-help/blob/main/terraform/tutorials/00001_-Setup%20Kubernetes%20Cluster%20on%20Docker%20with%20help%20of%20Kind.md)

