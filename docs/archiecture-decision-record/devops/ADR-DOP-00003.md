# ADR-DOP-00003

## Requirement

We should have a ability for monitoring DevOps resource cluster.

Version: 1.0.0

----------
## Decision Consideration 1
- We need to setup the monitoring service as part of the cluster to monitor the server instead of centralised the monitoring service.

**Advantage**

- Centralise monitoring service, it required have hug infrastructure setup to collect the data from all cluster service. 
- It increase the performance to keep each cluster monitoring
- Avoid central failure scenario

**Disadvantage**

- Maintain the multiple monitoring service, it will increase IT operation
- Increase cost of cluster resources
----------
## Decision Consideration 2
- We can use the Prometheus Monitoring Service for monitoring the Kubernetes cluster. 
- Prometheus service in build collect the apple metrics into in the Prometheus server from Kubernetes cluster. It helps us to easily collect metrics and monitor the cluster. Collecting metrics are pods memory usage, disk space usage etc.
----------
## Decision Consideration 3
- We can use the Grafana as visualisation tool the visualise Kubernetes cluster metrics. 
- Grafana already support to connect with Prometheus Server
- Grafana provides default template to metrics of Kubernetes cluster. It helps us to reduce for setup the different kind of visualisation which we can monitor the cluster resources. 


