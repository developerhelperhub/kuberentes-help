https://medium.com/@sujitthombare01/haproxy-smart-way-for-load-balancing-in-kubernetes-c2337f61d90b

helm repo add haproxytech https://haproxytech.github.io/helm-charts
helm repo update
helm install haproxy-ingress -f helm-value.yaml haproxytech/kubernetes-ingress --namespace haproxy-ingress --create-namespace

https://github.com/haproxytech/helm-charts/blob/main/kubernetes-ingress/values.yaml