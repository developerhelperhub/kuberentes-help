# 00004 - Maintain Module Version
This section offers a fundamental overview of Terraform versioning, particularly when working with multiple projects, collaborating with various team members, or setting up different environments. Additionally, I have published another post that explains how to create a [Terraform module for deploying Jenkins in a local Kubernetes cluster](https://dev.to/binoy_59380e698d318/terraform-module-design-jenkins-deployment-in-kubernetes-3276).

## Objective

In software architecture, it is important to consider qualities like maintainability, agility, and readability when building source code. These design considerations help enhance the overall quality of the application.

The module is maintained in a GitHub repository and is named "DevOps Terraform Module." Versioning can be managed in GitHub using commit IDs, tags, or branches. It is recommended to use tags for version management, as they provide a clear and easy-to-maintain approach, especially when dealing with multiple versions.

We can effortlessly set up DevOps resources in a local Kubernetes cluster using the following scripts.

**Root Main Terraform Script** `main.tf`
```shell
module "common" {
    source = "git::https://github.com/developerhelperhub/devops-terraform-module.git//modules/common?ref=v1.0.0"
}
module "devops" {
    source = "git::https://github.com/developerhelperhub/devops-terraform-module.git//devops?ref=v1.0.1"
    kind_cluster_name = var.kind_cluster_name
    kind_http_port = 80
    kind_https_port = 443
    kubernetes_namespace = "devops"
    jenkins_service_port = 8080
    jenkins_domain_name = var.jenkins_domain_name
    jenkins_admin_username = var.jenkins_admin_username
    jenkins_admin_password = module.common.random_password_16
}
```
Script `variabiles.tf`
```shell
#This is variable arguments while running the terraform scripts
variable "kind_cluster_name" {
    type = string
    description = "Kind cluster name"
}
variable "jenkins_domain_name" {
    type = string
    description = "Jenkins domain name"
    default = "jenkins.devops.com"
}
variable "jenkins_admin_username" {
    type = string
    description = "Jenkins admin username"
    default = "test_admin"
}
```

## Setup local environment to build DevOps resources

I use docker containers to set up work environments for multiple applications([Setup Environment](https://dev.to/binoy_59380e698d318/setup-linux-box-on-local-with-docker-container-3k8)). This approach ensures fully isolated and maintainable environments for application development, allowing us to easily start and terminate these environments. Below is the Docker command to create the environment.
```shell
docker run -it --name test-jenkins-module-envornment-box -v ~/.kube/config:/work/.kube/config -e KUBECONFIG=/work/.kube/config -v ${HOME}/root/ -v ${PWD}/work -w /work --net host developerhelperhub/kub-terr-work-env-box
```
The container contains Docker, Kubectl, Helm, Terraform, Kind, Git

## Setup Jenkins on Kubernetes Cluster 

I have created all the Terraform scripts, which are available in the GitHub repository. You can download and set up Jenkins on a Kubernetes cluster, which runs locally in a Docker container.

**Clone the repository** onto your local Linux machine to get started.
```shell
git clone https://github.com/developerhelperhub/kuberentes-help.git
cd kuberentes-help/terraform/sections/00004/
```
Run the following commands to install the resources
```shell
terraform init

#Create the workspace to keep the separate the terraform state files of dev and production. This helps us to maintain multiple running in local
terraform workspace new devops_testing
terraform workspace select devops_testing

terraform plan
terraform apply  -var="kind_cluster_name=devops-test-cluster"  -var="jenkins_admin_username=my_test_admin"
```

**Note:** The Terraform state file should be kept secure and encrypted (using encryption at rest) because it contains sensitive information, such as usernames, passwords, and Kubernetes cluster details etc.

Add our domain to the bottom of the `/etc/hosts` file on your local machine. This configuration should not be inside our working Linux box “test-jenkins-module-envornment-box”; it should be applied to your personal machine's `/etc/hosts` file. 
(you will need administrator access):
```shell
127.0.0.1 jenkins.devops.com
```

We can open the Jenkins UI in the browser “http://jenkins.devops.com/”
**Note**: Username and password will be available in the Terraform state file

**Destroy and clean the resources**
Following command can be used clean all resources which installed by Terraform and its supporting files

I have created a shell script which clean all terraform generated files and folders `terraform-clean.sh`
```shell
#!/bin/bash
# Remove the .terraform directory
echo "Removing .terraform directory..."
rm -rf .terraform
rm -rf .terraform.lock.hcl
# Remove Terraform state files
echo "Removing terraform.tfstate and terraform.tfstate.backup..."
rm -f terraform.tfstate terraform.tfstate.backup
rm -rf terraform.tfstate.d
# Remove Terraform plan files
echo "Removing *.plan files..."
rm -f *.plan

echo "Removing *-config files of kind..."
rm -f *-config
echo "Terraform cleanup completed."
```

Following command can be used to clean resources, folder and files
```shell
terraform destroy -var="kind_cluster_name=devops-test-cluster"
terraform workspace select default
terraform workspace delete devops_testing

chmod +x terraform-clean.sh
sh ./terraform-clean.sh
```

## References
- https://github.com/developerhelperhub/devops-terraform-module
- https://developer.hashicorp.com/terraform/language/modules/sources#git-https-example-com-network-git-modules-vpc

