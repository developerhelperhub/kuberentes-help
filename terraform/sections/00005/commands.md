terraform init
terraform init -upgrade

terraform workspace new devops_testing
terraform workspace select devops_testing

terraform plan
terraform apply  -var="kind_cluster_name=devops-test-cluster"
terraform destroy -var="kind_cluster_name=devops-test-cluster"

terraform workspace select default
terraform workspace delete devops_testing

chmod +x terraform-clean.sh
./terraform-clean.sh


# References
* https://developer.hashicorp.com/terraform/tutorials/modules/pattern-module-creation
* https://blog.gruntwork.io/how-to-create-reusable-infrastructure-with-terraform-modules-25526d65f73d

docker run -it --name test-jforg-module-envornment-box -v ~/.kube/config:/work/.kube/config -e KUBECONFIG=/work/.kube/config -v ${HOME}:/root/ -v ${PWD}:/work -w /work --net host developerhelperhub/kub-terr-work-env-box