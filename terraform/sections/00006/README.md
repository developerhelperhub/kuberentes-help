# 00006 - Module Jenkins Agent Maven Configuration in Kubernetes 
This section explains how to setup the Maven Jenkins Agent Configuration on Kubernetes cluster. I have created the terraform module to install easily maven related agent configuration in our cluster.  

![](https://paper-attachments.dropboxusercontent.com/s_401C97B6AA64C2206C9536775BD2DC6090E76D319E52847E1FFEDEFDC71E5429_1725786297636_devops-Jenkins+Deployment.drawio+1.png)


[This architecture already explain other article.](https://dev.to/binoy_59380e698d318/setup-efficient-cicd-pipeline-jenkins-to-build-binary-and-push-docker-image-on-kubernetes-cluster-4f8d)

## Following benefits are looking 

**Local Dependency Caching:** Implement local caching of dependencies to reduce build times.
**Maintain the Artifactory in development**: Ensue we have install the Artifactory in our infrastructure to store the application dependencies, application libraries to get the following benefits

    - Get the control and secure the dependencies of application
    - Get the cache the application dependencies to avoid the download time, we know the Kubernetes cluster running on multiple nodes
    - Use the same dependencies and libraries by the team and CICD Pipeline
    - We can add the retention policy to delete the unused dependencies and reduce the storage cost
    - We can use JFrog Artifactory as proxy server to connect the build tools for downloading the dependencies for our applications instead of directly downloading from maven central repository
## Setup modules resource in locally Kubernetes Cluster

Following command helps to easily setup the resources
**Setup working environment in Docker container**
```shell
docker run -it --name working-envornment-box -v ~/.kube/config:/work/.kube/config -e KUBECONFIG=/work/.kube/config -v ${HOME}:/root/ -v ${PWD}:/work -w /work --net host developerhelperhub/kub-terr-work-env-box
```
**Download the Terraform Script in docker container**
```shell
git clone https://github.com/developerhelperhub/kuberentes-help.git
cd kuberentes-help/terraform/sections/00006/terraform
```
Following setup done before creating the resources. These setups already explained in the [article](https://dev.to/binoy_59380e698d318/setup-efficient-cicd-pipeline-jenkins-to-build-binary-and-push-docker-image-on-kubernetes-cluster-4f8d).

- Configure the domain name in /etc/hosts
- Create the artifactory repositories in the JFrog
- Generate the maven master password
- Generate the admin password encrypted password through maven

**Configure the Environment variables of Maven Secretes for Maven Agent Config Module**
Following the environments variables need to configure in the `~/.bash_profile`, give the proper encrypted password and user names in the variables
```shell
export set TF_VAR_jenkins_agent_maven_config_app_repository_username="<user>"
export set TF_VAR_jenkins_agent_maven_config_app_repository_password="<password>"
export set TF_VAR_jenkins_agent_maven_config_app_central_repository_username="<user>"
export set TF_VAR_jenkins_agent_maven_config_app_central_repository_password="<password>"
export set TF_VAR_jenkins_agent_maven_config_maven_master_password="<maven master password>"
```
Refresh the bash_profile and verify the environment variables whether configured properly or not
```shell
source ~/.bash_profile

echo $TF_VAR_jenkins_agent_maven_config_app_repository_username
echo $TF_VAR_jenkins_agent_maven_config_app_repository_password
echo $TF_VAR_jenkins_agent_maven_config_app_central_repository_username
echo $TF_VAR_jenkins_agent_maven_config_app_central_repository_password
echo $TF_VAR_jenkins_agent_maven_config_maven_master_password
```
Terraform Script for setup resources 
```shell
module "devops" {
  source = "git::https://github.com/developerhelperhub/devops-terraform-module.git//devops?ref=v1.2.0"
  kind_cluster_name = var.kind_cluster_name
  kind_http_port    = 80
  kind_https_port   = 443
  kubernetes_namespace = "devops"

  jenkins_enable         = true
  jenkins_domain_name    = var.jenkins_domain_name
  jenkins_admin_username = var.jenkins_admin_username
  # if we are not configure password, module automatically generated the password and it available in the terraform state file
  jenkins_admin_password = "TestPasswordA2002"

  jfrog_enable              = true
  jfrog_domain_name         = var.jfrog_domain_name

  jenkins_agent_maven_config_enabled = true
  jenkins_agent_maven_config_pvc_storage_size = "5Gi"
  jenkins_agent_maven_config_pv_storage_size = "5Gi"

  jenkins_agent_maven_config_app_repository_id="my-app-virtual-snapshot"
  jenkins_agent_maven_config_app_repository_url="http://jfrog-artifactory-oss.devops.svc.cluster.local:8081/artifactory/my-app-virtual-snapshot/"
  jenkins_agent_maven_config_app_repository_username=var.jenkins_agent_maven_config_app_repository_username
  jenkins_agent_maven_config_app_repository_password=var.jenkins_agent_maven_config_app_repository_password

  jenkins_agent_maven_config_app_central_repository_id="my-app-central-snapshot"
  jenkins_agent_maven_config_app_central_repository_url="http://jfrog-artifactory-oss.devops.svc.cluster.local:8081/artifactory/my-app-central-snapshot"
  jenkins_agent_maven_config_app_central_repository_username=var.jenkins_agent_maven_config_app_central_repository_username
  jenkins_agent_maven_config_app_central_repository_password=var.jenkins_agent_maven_config_app_central_repository_password
  jenkins_agent_maven_config_maven_master_password=var.jenkins_agent_maven_config_maven_master_password
}
```

Run the following command to install the resources
```shell
cd kuberentes-help/terraform/sections/00006/

terraform init
terraform plan -var="kind_cluster_name=devops-test-cluster"
terraform apply -var="kind_cluster_name=devops-test-cluster"
```
Once resources installed completed following command used to verify the resources are installed and configured properly or not

**Verify the maven repository storage**
Persistence Volume and Persistence Volume Claim “jenkins-agent-maven-repo-pv” and "jenkins-agent-maven-repo-pvc”
```shell
kubectl -n devops get pv
kubectl -n devops get pvc
```
**Verify the maven settings and security**
Created the ConfigMap and Secrete “jenkins-agent-maven-settings” and “jenkins-agent-maven-credentials”
```shell
kubectl -n devops get configmap jenkins-agent-maven-settings
kubectl -n devops get secret jenkins-agent-maven-credentials
```
Now we can create the Jenkins pipeline with following script. This already explain this [article](https://dev.to/binoy_59380e698d318/setup-efficient-cicd-pipeline-jenkins-to-build-binary-and-push-docker-image-on-kubernetes-cluster-4f8d).
```shell
pipeline {
  agent {
    kubernetes {
      yaml'''
apiVersion: v1
kind: Pod
metadata:
  name: graalvm-22-muslib-maven-jenkins-agent-template
  labels:
    app: jenkins-agent
spec:
  containers:
  - name: builder
    image: developerhelperhub/graalvm-22-muslib-maven:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - name: maven-credentials
      mountPath: /root/.m2/settings-security.xml
      subPath: settings-security.xml
    - name: maven-settings
      mountPath: /root/.m2/settings.xml
      subPath: settings.xml
    - name: maven-repo
      mountPath: /root/.m2
  - name: docker
    image: docker:latest
    env:
    - name: DOCKER_HOST
      value: "tcp://172.17.0.1:2375"
    command:
    - cat
    tty: true
    volumeMounts:
      - mountPath: /var/run/docker.sock
        name: docker-sock
  volumes:
  - name: maven-repo
    persistentVolumeClaim:
      claimName: jenkins-agent-maven-repo-pvc
  - name: maven-settings
    configMap:
      name: jenkins-agent-maven-settings
  - name: maven-credentials
    secret:
      secretName: jenkins-agent-maven-credentials
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock  
      '''
    }
  }
  stages {
    stage('Clone Application Git Repo') {
      steps {
        container('builder') {
          git branch: 'main', changelog: false, poll: false, url: 'https://github.com/developerhelperhub/spring-boot-graalvm-jenkins-pipeline.git'
        }
      }
    }  
    stage('Build Native Image and Compress') {
      steps {
        container('builder') {
          sh '''
            cd spring-boot-rest-api-app
            mvn deploy 
            ls
          '''
        }
      }
    }
  }
}
```

This helps us to reduce the drastically reduce the build time
**Initial Build time is** 

![](https://paper-attachments.dropboxusercontent.com/s_401C97B6AA64C2206C9536775BD2DC6090E76D319E52847E1FFEDEFDC71E5429_1725788387371_image.png)

----------

**Second Build time is**

![](https://paper-attachments.dropboxusercontent.com/s_401C97B6AA64C2206C9536775BD2DC6090E76D319E52847E1FFEDEFDC71E5429_1725788434707_image.png)



# Reference
- [Setup efficient CICD Pipeline Jenkins to build binary and push docker image - Kubernetes cluster](https://dev.to/binoy_59380e698d318/setup-efficient-cicd-pipeline-jenkins-to-build-binary-and-push-docker-image-on-kubernetes-cluster-4f8d)
- [Terraform DevOps Model](https://github.com/developerhelperhub/devops-terraform-module/tree/main)
- Terraform DevOps Example
[](https://github.com/developerhelperhub/devops-terraform-module/tree/main)
