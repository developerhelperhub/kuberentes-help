# ADR-DOP-00005

## Requirement

We should have capable to setup quickly developer environment, it helps to onboard team and start use the environment.

Version: 1.0.0

----------
## Decision Consideration 1
- We can use the Terrafrom to setup the developer environment instead of manully install / setup the resources in the system
----------
## Decision Consideration 2
- We can use the Apline Linux box and docker container to setup the environment for development. 
- It is small instance and provides the better resource utilisation
- It is provide highly security in build
- We can quickly start and stop the container
- Delete the container whenever require
----------
##  Decision Consideration 3
- We can use different container for dev, qa and production
- It provide better isolation of working environment 
- Avoid the unexpected error while deploying the application in specific environment
----------


![](https://paper-attachments.dropboxusercontent.com/s_432208D5A406CF69B23E687A9BE705DDC5033297691B263E4F5C75F83F44F854_1721458736937_devops.drawio.png)


 

