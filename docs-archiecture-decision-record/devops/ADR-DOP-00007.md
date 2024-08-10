# ADR-DOP-00007

## Requirement

System should capable to build binary from java application, create the docker image, push image to docker container registry, with help of CICD tool.

Version: 1.0.0

----------
## Decision Consideration 1
- The Jenkins CI/CD tool should be deployed on a Kubernetes cluster.
- Jenkins should operate within the DevOps namespace.
- The build process should run on Jenkins agents that are dynamically created within the Kubernetes cluster. This setup enhances scalability, allows agents to be started and stopped quickly, and efficiently utilizes the cluster's resources compared to VM-based agents.
----------
## Decision Consideration 2
- Cache dependencies across pods to reduce build times and minimize unnecessary network and resource utilization.
----------
## Decision Consideration 3
- To efficiently scale microservices, the service should be capable of rapid scaling. Achieving this requires a CI/CD pipeline capable of building the application with the following technologies and tools:
    - Utilize GraalVM for Ahead-of-Time (AOT) compilation of the Java application, generating a binary that offers a better memory footprint and faster startup times.
    - Compress the generated binary using the UPX tool.
    - Run the compressed binary in a container, ensuring the container is small, secure, and based on Alpine Linux. Build the image using Alpine Linux as the base and expose the necessary ports.
    - Push the Docker image to a container registry, such as Docker Hub.
----------
## Decision Consideration 4
- Securely store service credentials within the CI/CD tool.
- Verify dependencies, compile the binary, execute test cases, and package the binary.

