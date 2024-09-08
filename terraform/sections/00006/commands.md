```shell
terraform workspace new development
terraform workspace select development

terraform init
terraform init -upgrade

terraform plan -var="kind_cluster_name=devops-development-cluster"
terraform apply  -var="kind_cluster_name=devops-development-cluster"
terraform destroy -var="kind_cluster_name=devops-development-cluster"
```

```shell
chmod +x terraform-clean.sh
./terraform-clean.sh
```

Replace fast-storage with the actual name of the storage class available in your Kubernetes cluster.
If you're unsure which storage classes are available, you can list them using:
```shell
kubectl get storageclass
```
This will show you the available storage classes, which you can reference in your Terraform configuration.

```shell
kubectl -n devops describe pvc/jenkins-maven-repo-pvc
```
vi ~/.bash_profile
```shell
export set TF_VAR_jenkins_agent_maven_config_app_repository_username="<user>"
export set TF_VAR_jenkins_agent_maven_config_app_repository_password="<password>"
export set TF_VAR_jenkins_agent_maven_config_app_central_repository_username="<user>"
export set TF_VAR_jenkins_agent_maven_config_app_central_repository_password="<password>"
export set TF_VAR_jenkins_agent_maven_config_maven_master_password="<maven master password>"
```
source ~/.bash_profile

```shell
echo $TF_VAR_jenkins_agent_maven_config_app_repository_username
echo $TF_VAR_jenkins_agent_maven_config_app_repository_password
echo $TF_VAR_jenkins_agent_maven_config_app_central_repository_username
echo $TF_VAR_jenkins_agent_maven_config_app_central_repository_password
echo $TF_VAR_jenkins_agent_maven_config_maven_master_password
```