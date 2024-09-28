```shell
terraform workspace new microservices_dev
terraform workspace select microservices_dev

terraform init
terraform init -upgrade

terraform plan -var="kind_cluster_name=microservices-development-cluster"
terraform apply -var="kind_cluster_name=microservices-development-cluster"
```

**Deploy Item Service**
```shell
kubectl -n microservices -f microservices/item-service/kube-deployment.yaml apply
kubectl -n microservices -f microservices/item-service/kube-service.yaml apply

kubectl -n microservices get pod
kubectl -n microservices get svc
```

**Deploy Order Service**
```shell
kubectl -n microservices -f microservices/order-service/kube-deployment.yaml apply
kubectl -n microservices -f microservices/order-service/kube-service.yaml apply

kubectl -n microservices get pod
kubectl -n microservices get svc
```

**Clean resources**
```shell
terraform destroy -var="kind_cluster_name=microservices-development-cluster"
```

```shell
chmod +x terraform-clean.sh
./terraform-clean.sh
```
