# WRK-ENV-00002-Maintain the proper naming convention and tagging for resources throughout development
We need to adhere to proper naming conventions and tagging throughout our entire environment setup, including infrastructure, application, and network resources. This practice enhances the quality attributes of our software architecture, such as maintainability, readability, and supportability.

Each project is assigned a unique name from the start of the software development life cycle. We must maintain or provide an abbreviation for the project, which will be used whenever creating or adding resources and configurations in the software. Most companies have multiple projects, requiring resources to be created in different environments.

For example, we manage two AWS accounts: a 'Non-Production Account' that includes environments like dev, QA, and staging, and a 'Production Account' that includes environments such as prod and test. The specific environments can vary based on client requirements and cost considerations.

For example, If the project name is “My E-commerce Site” and short name called “mes”.


- {project short name}-{environment}-{resource-name}
- {mes}-{local/dev/prod}-{devops-working-env}

We should also provide tagging when grouping resources, associating different sets of tags based on factors such as the project, resource type, and business domain. 

**Tag is key value pair. For example**

| Key           | Value                                                          |
| ------------- | -------------------------------------------------------------- |
| Project       | MES                                                            |
| Env           | Dev / QA / UAT / Prod                                          |
| Resource Layer| Database / Web / Backend / Infrastructure / Network / Security |
| Resource Type | Database / Frontend Service / Micorservice / Messaging etc.    |

We need to maintain consistency throughout the entire software development life cycle to ensure the maintainability of the software.

