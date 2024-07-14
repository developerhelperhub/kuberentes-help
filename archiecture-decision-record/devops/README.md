# README
As software application, we should have capability maintains all DevOps related operation service which can support the development application.  For that , we are setting-up / installing all services should run in the Kubernetes Cluster


![](https://paper-attachments.dropboxusercontent.com/s_C9BF48A8640DC749A738019594587BDE491C37C126406C84793D459A60AEAFA9_1720804566432_Kubernetes-DevOps.drawio.png)


Above the high level architecture to run the services and connect these service from outside. We are using ingress to connect the multiple application in the Kubernetes cluster

| ADR Number | Description                                                                           |
| ---------- | ------------------------------------------------------------------------------------- |
| ADR-00001  | We should have fully isolation between our application resources and DevOps resource. |
| ADR-00002  | Our application should capable to quickly build, test and deploy                      |


