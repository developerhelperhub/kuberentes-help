# 0001-Kubernetes


## Install Test Application

Create a sample deployment and expose it on port 8080:

    kubectl create deployment hello-minikube --image=kicbase/echo-server:1.0
    kubectl expose deployment hello-minikube --type=NodePort --port=8080

It may take a moment, but your deployment will soon show up when you run:

    kubectl get services hello-minikube

The easiest way to access this service is to let minikube launch a web browser for you:

    minikube service hello-minikube

Alternatively, use kubectl to forward the port:

    kubectl port-forward service/hello-minikube 7080:8080

Tada! Your application is now available at [http://localhost:7080/](http://localhost:7080/).
You should be able to see the request metadata in the application output. Try changing the path of the request and observe the changes. Similarly, you can do a POST request and observe the body show up in the output.

## Delete Namespace


    kubectl delete namespace jenkins


## Uninstall Minikube
    minikube stop
    minikube delete 
    docker stop $(docker ps -aq) # Stop all docker containers
    rm -rf ~/.kube ~/.minikube
    sudo rm -rf /usr/local/bin/localkube /usr/local/bin/minikube 
    launchctl stop '*kubelet*.mount'
    launchctl stop localkube.service
    launchctl disable localkube.service # issue on this task
    sudo rm -rf /etc/kubernetes/
    docker system prune -af --volumes


## Setup Ingress

https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/



    minikube addons enable ingress

Verify that the NGINX Ingress controller is running

    kubectl get pods -n ingress-nginx

Create `example-ingress.yaml` from the following file:


    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: hello-minikube
    spec:
      ingressClassName: nginx
      rules:
        - host: hello-minikube.example
          http:
            paths:
              - path: /
                pathType: Prefix
                backend:
                  service:
                    name: hello-minikube
                    port:
                      number: 8080

Create the Ingress object by running the following command:

    kubectl apply -f example-ingress.yaml

Verify the IP address is set:

    kubectl get ingress

Note:
The network is limited if using the Docker driver on MacOS (Darwin) and the Node IP is not reachable directly. To get ingress to work you’ll need to open a new terminal and run `minikube tunnel`.
`sudo` permission is required for it, so provide the password when prompted.


    minikube tunnel

you can also visit `hello-world.example` from your browser.
Add a line to the bottom of the `/etc/hosts` file on your computer (you will need administrator access):


    127.0.0.1 hello-world.example

After you make this change, your web browser sends requests for `hello-world.example` URLs to Minikube.


