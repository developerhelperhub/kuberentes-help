# README
As software application, we should have capability maintains all DevOps related operation service which can support the development application.  For that , we are setting-up / installing all services should run in the Kubernetes Cluster

| **ADR Number** | **Description**                                                                                                                            | **Version** |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| ADR-DOP-00001  | We should have fully isolation between our application resources and DevOps resource.                                                      | 1.0.0       |
| ADR-DOP-00002  | Our application should capable to quickly build, test and deploy                                                                           | 1.0.0       |
| ADR-DOP-00003  | We should have a ability for monitoring DevOps resource cluster                                                                            | 1.0.0       |
| ADR-DOP-00004  | Infrastructure provision should be quick, if any disaster / attack happen, our application should infrastructure should setup very quickly | 1.0.0       |
| ADR-DOP-00005  | We should have capable to setup quickly developer environment, it helps to onboard team and start use the environment                      | 1.0.0       |
| ADR-DOP-00006  | Maintain the proper naming convention, it helps us to easily understand and maintain the resource in the cloud.                            | 1.0.0       |

## Dev Ops Service deployment in Kubernetes Cluster
![](https://paper-attachments.dropboxusercontent.com/s_2161CEC8E508F2CE54D7346FAD60D67DA570D3B8F3BF4177979F1EEE19417CE5_1720970183719_Kubernetes-DevOps.drawio+1.png)


Above the high level architecture to run the services and connect these service from outside. We are using ingress to connect the multiple application in the Kubernetes cluster

