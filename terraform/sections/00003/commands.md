terraform init
terraform init -upgrade

terraform workspace new devops_testing
terraform workspace select devops_testing

terraform plan
terraform apply  -var="kind_cluster_name=devops-test-cluster"  -var="jenkins_admin_username=my_test_admin"
terraform destroy -var="kind_cluster_name=devops-test-cluster"

terraform workspace select default
terraform workspace delete devops_testing

terraform workspace new devops_prod
terraform workspace select devops_prod

terraform plan
terraform apply  -var="kind_cluster_name=devops-prod-cluster" -var="jenkins_admin_username=prod_admin"
terraform destroy -var="kind_cluster_name=devops-prod-cluster"

terraform workspace select default
terraform workspace delete devops_prod

chmod +x terraform-clean.sh
./terraform-clean.sh


# References
* https://developer.hashicorp.com/terraform/tutorials/modules/pattern-module-creation
* https://blog.gruntwork.io/how-to-create-reusable-infrastructure-with-terraform-modules-25526d65f73d



docker run -it --name test-jenkins-module-envornment-box -v ~/.kube/config:/work/.kube/config -e KUBECONFIG=/work/.kube/config -v ${HOME}:/root/ -v ${PWD}:/work -w /work --net host developerhelperhub/kub-terr-work-env-box