# ADR-DOP-00004

## Requirement

Infrastructure provision should be quick, if any disaster / attack happen, our application should infrastructure should setup very quickly.

Version: 1.0.0

----------
## Decision Consideration 1
- We can use the “Infrastructure as Code” process in our application development, it is ability to provision and support your computing infrastructure using code instead of manual processes and settings.
- This code can be reuse to provision application infrastructure very quickly
- Terraform can be used to create and configure entire Kubernetes clusters on various cloud platforms, such as AWS, Google Cloud, and Azure. By defining the cluster infrastructure as code, you can easily replicate and manage the setup across different environments.
- Once a Kubernetes cluster is provisioned, Terraform can manage the deployment of applications and other resources (e.g., namespaces, services, deployments) within the cluster.
- Terraform allows you to scale your Kubernetes clusters and update configurations easily by modifying the Terraform configuration and reapplying it. This can include scaling the number of worker nodes, updating instance types, or changing resource configurations.
----------
## Decision Consideration 2
- We use the common process to provision for all infrastructure resources and service in application. For example, if we are using different tools to setup the application we have to use different type script need to maintain. when we use Terrform most of infrastructure service can be deploy it.
----------
## References
- REF000000005
- REF000000006
