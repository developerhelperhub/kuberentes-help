# 00001-Create Local Application cluster
We need to create Kubernetes cluster to develop application in local environment. This cluster is used to install the tools and applications which we need to connect with local development environment. For example, we need to setup a database :


- Database 
- Authentication Sever
- ActiveMQ
- Kafka
- Elasticsearch
- Etc.

While development and testing we need to expose the NodePort to establish the connection between local environment and local Kubernetes cluster.

