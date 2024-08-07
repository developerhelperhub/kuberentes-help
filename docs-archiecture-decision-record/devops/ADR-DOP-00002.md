# ADR-DOP-00002

## Requirement

Our application should capable to quickly build, test and deploy our application.

Version: 1.0.0

----------
## Decision Consideration 1

We can use Jenkins for CICD as part of DevOps operation.


1. **Extensibility**:
    - Over 1,500 plugins are available to extend Jenkins' functionality, integrating with a wide range of tools and services.
    - Custom plugins can be developed to meet specific needs.
2. **Community and Support**:
    - Large, active community offering extensive documentation, tutorials, and forums for support.
    - Regular updates and contributions from the open-source community.
3. **Flexibility**:
    - Supports diverse environments, languages, and technologies.
    - Can be deployed on-premises or in the cloud, offering scalability and flexibility.
4. **Pipeline as Code**:
    - Uses a domain-specific language (DSL) called Jenkinsfile to define CI/CD pipelines as code, enabling version control and collaboration.
    - Supports both declarative and scripted pipeline syntax.
5. **Scalability**:
    - Master-slave architecture allows scaling by adding more build agents (slaves) to distribute the workload.
    - Supports clustering and load balancing for high availability.
6. **User-Friendly Interface**:
    - Intuitive web-based GUI for configuring and managing jobs and pipelines.
    - Supports integration with other interfaces, such as Blue Ocean for a modern and improved user experience.
7. **Security**:
    - Offers robust security features, including user authentication, role-based access control, and integration with external authentication systems.
    - Supports secure communication through SSL/TLS.


----------
## References
- REF000000004

