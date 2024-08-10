# ADR-DOP-00006

## Requirement

Maintain the proper naming convention, it helps us to easily understand and maintain the resource in the cloud.

Version: 1.0.0

----------
## Decision Consideration 1
- We need to adhere to proper naming conventions and tagging throughout our entire environment setup, including application, tools, configurations etc.. 
- This practice enhances the quality attributes of our software architecture, such as maintainability, readability, and supportability.
----------
## Decision Consideration 2
- Kubernetes cluster, we can create “DevOps” namespace to get full isolation of resources, configurations, security and provide specific roles and permission
- Each project has different environments dev, qa, uat and production. The DevOps resources / applications considers as common resources for a project

For example, resources of specific application, we may create different Kubernetes cluster such as

- Development, in this cluster, we have different environment in development cycle
    - dev
    - qa
- Production in this cluster, we have different environment the customer using application
    - UAT
    - Production
- The We can use common DevOps cluster which run the Development Operation tools run and maintain


----------
## Decision Consideration 3

We should also provide tagging when grouping resources, associating different sets of tags based on factors such as the project, resource type. 

**Tag is key value pair. For example**

| Key           | Value             |
| ------------- | ----------------- |
| Env           | DevOps            |
| Resource Type | Monitoring, CI/CD |

We need to maintain consistency throughout the entire software development life cycle to ensure the maintainability of the software.

