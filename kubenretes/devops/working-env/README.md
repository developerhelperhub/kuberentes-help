# README

## Aplien Linux Box

We have to setup a Apline Linux Box for each environment like development, production, etc. This linux container DevOps team use for working there development task.

For example:


![](https://paper-attachments.dropboxusercontent.com/s_3E1DC0FE6FD336ACFF9B2C07147BA02D55071C39E34DB09968E3A8F6E7EA7CDB_1721459665716_devops.drawio.png)


Project name is “My Ecommerce Site” and short name called “mes”. Normally I am following the proper naming convention for entire architecture, it helps to easily maintain and understand resource.


- {project short name}-{environment}-{resource-name}
- {mes}-{dev/prod}-{devops-working-env}


    docker run -it --name mes-dev-devops-working-env -v ${HOME}:/root/ -v ${PWD}:/work -w /work --net host alpine sh
    
    docker existing container shell access
    
    docker exec -it mes-dev-devops-working-env sh


## Install the Curl

Curl a command line tool that developers use to transfer data to and from a server. 

    apk add --no-cache curl


## Install Kuberentes “kubectl”

Kubectl is the command line configuration tool for Kubernetes. 

    curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
    
    chmod +x ./kubectl
    
    mv ./kubectl /usr/local/bin/kubectl


## Install Terrafrom

I have installed the Terraform [terraform_1.9.2](https://releases.hashicorp.com/terraform/1.9.2/) version. We can download latest install file from Terraform site “https://releases.hashicorp.com/terraform/”


    wget https://releases.hashicorp.com/terraform/1.9.2/terraform_1.9.2_linux_386.zip -P /tmp/
    
    unzip /tmp/terraform_1.9.2_linux_386.zip -d /usr/local/bin
    
    terraform --version



## Reference
- https://phoenixnap.com/kb/how-to-install-terraform

