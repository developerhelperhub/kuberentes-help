# ADR-DOP-00008

## Requirement

System should capable to maintain the applications artifactories and central dependencies inside application network

Version: 1.0.0

----------
## Decision Consideration 1
- The JFrog open source artifactory application can be used to store the maven dependencies and application artifiactory in our application.
- JFrog provided Open Source and we can easily install in the Kubernetes cluster with Helm chart.
- JFrog Artifactory allows you to control access to your artifacts with fine-grained permissions. You can manage who can upload, download, or delete artifacts. It also integrates with security tools to scan artifacts for vulnerabilities.
- Artifactory acts as a proxy for external repositories (e.g., Maven Central, npm registry). It caches downloaded artifacts locally, reducing the need to fetch the same dependencies repeatedly from external sources.
- Artifactory ensures that all users and CI/CD pipelines are pulling the exact same versions of artifacts. This consistency helps prevent "works on my machine" issues and ensures stable builds across different environments.
- You can create as many repositories as you need in Artifactory, each tailored to different teams, projects, or stages of development. This is particularly useful for managing dependencies in different environments or for separating open-source components from proprietary ones.
- Artifactory allows you to set up automated retention policies to clean up old or unused artifacts, ensuring efficient use of storage space.
- Artifactory supports multi-site replication, enabling you to synchronize repositories across multiple locations. It also offers high availability configurations to ensure your artifacts are always accessible
----------
## Decision Consideration 2

Using an Artifactory instance for managing your application's artifacts instead of relying solely on a central repository like Maven Central or npm registry offers several benefits:

1. **Control and Security**: Hosting your own Artifactory allows you to have full control over your artifacts. You can manage access permissions, ensure that only trusted packages are used, and apply security policies such as vulnerability scanning.
2. **Local Cache**: Artifactory can cache dependencies from central repositories locally. This reduces download times, saves bandwidth, and provides resilience against network issues or outages of external repositories.
3. **Consistency**: By using your own Artifactory, you ensure that all developers and CI/CD pipelines are using the same versions of dependencies. This eliminates inconsistencies caused by different developers fetching dependencies at different times from the central repository.
4. **Custom Repositories**: You can create and manage multiple repositories for different teams, environments, or stages of development (e.g., development, testing, production). This is particularly useful for managing different versions of artifacts or for separating open-source and proprietary components.
5. **Retention Policies**: Artifactory allows you to implement retention policies to automatically remove unused or outdated artifacts, helping you manage storage space efficiently.
6. **Build Integration**: Artifactory integrates with popular CI/CD tools like Jenkins, GitLab, and GitHub Actions, enabling automatic artifact storage and management as part of your build process. This can help automate deployment pipelines and improve overall efficiency.
7. **Support for Multiple Package Types**: Artifactory supports various package formats (e.g., Maven, npm, NuGet, PyPI, Docker, etc.), making it a versatile solution for managing all types of build artifacts in one place.
8. **Replication and High Availability**: Artifactory supports replication between multiple instances, providing redundancy and high availability. This is particularly beneficial for large organizations with teams spread across different geographic locations.
----------
## Decision Consideration 3
- JFrog Artifactory integrates seamlessly with popular CI/CD tools like Jenkins, GitLab, and GitHub Actions. It provides plugins and APIs to automate artifact storage and management as part of your build and deployment pipelines.

