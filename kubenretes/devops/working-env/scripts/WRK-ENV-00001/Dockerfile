FROM amd64/alpine

ENV DOCKER_HOST=tcp://localhost:2375

#Install Docker and start docker
RUN apk add --update docker openrc 
RUN rc-update add docker boot
CMD service docker start

#Install curl
RUN apk add --no-cache curl

#Install Kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.30.3/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl

#Install Kind
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
RUN chmod +x ./kind
RUN mv ./kind /usr/local/bin/kind

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/1.9.3/terraform_1.9.3_linux_amd64.zip -P /tmp/
RUN unzip /tmp/terraform_1.9.3_linux_amd64.zip -d /usr/local/bin

# Install Helm
RUN curl -o /tmp/helm.tar.gz -LO https://get.helm.sh/helm-v3.10.1-linux-amd64.tar.gz
RUN tar -C /tmp/ -zxvf /tmp/helm.tar.gz
RUN mv /tmp/linux-amd64/helm /usr/local/bin/helm
RUN chmod +x /usr/local/bin/helm

# Install Git
RUN apk add git

WORKDIR /work

ENTRYPOINT sh