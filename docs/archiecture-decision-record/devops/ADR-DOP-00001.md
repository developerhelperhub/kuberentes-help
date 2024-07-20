# ADR-DOP-00001

## Requirement

We should have fully isolation between our application resources and DevOps resource.

Version: 1.0.0

----------
## Decision Consideration 1

We creates specific a namespace for DevOps related services. This helps to maintains the resources, security, isolation, monitoring, etc. for these service.  


- Separate namespaces for different environments can help manage and isolate resources and workloads.
- Different roles and permissions can be assigned to users or service accounts within specific namespaces, providing fine-grained access control.
- Namespaces provide a way to logically group related resources, making it easier to manage and navigate through the cluster.
- Limit ranges can be defined to specify the minimum and maximum compute resources that can be requested by containers in a namespace, helping to control resource allocation and utilization.
----------
## Decision Consideration 2
****
We creates separate Kubernetes cluster for this workload. 


- Create isolated environments for monitoring, deploying, upgrading, installing the DevOps related services to ensuring that changes do not affect other workloads.
- Identify the issues in a controlled environment, making it easier to diagnose and fix them.
- Reduce the security issue and risk if any cyber attack happen and reduce the affected area of the system
----------
## References
- REF000000001
- REF000000002 

