# ADR-MCS-00003

## Requirement

We should provide API gateway to communicate the Microservice

Version: 1.0.0

----------
## Design Consideration 1
****- In a Microservice architecture, multiple Microservices need to be built based on the requirements and functionalities.
- We should provide an API gateway to connect clients to microservices. This approach allows these microservices to run within a private network, preventing direct client access to the microservices.
----------
## Design Consideration 2
- Authentication, authorization, and SSL termination can be handled at the API gateway level based on business needs.
- This approach reduces complexity and improves performance. 
----------
## Design Consideration 3
- API Gateway should have capability to monitor and trace the requests 
----------
## Design Consideration 4
- We are consider the comparison between Kong API gateway and Spring Cloud API Gateway. 
- As per the analyse, we are selecting the Kong API gateway, the following features and functionalities
    - Provides high scalabilities and performances
    - Simple configure the endpoints to API gateway 
    - Support Authentication and Authorisation
    - Provides monitoring and tracing requests and responses
    - Able to connect the Prometheus Monitoring Service
    - We can easily deploy this on Kubernetes with help of Helm package manager
----------
## Design Consideration 5
- When building microservices for banking, insurance, or healthcare domains, we should consider end-to-end authorization and SSL encryption/decryption.
- In this approach, authorization and validation are implemented at the microservices level.
- Within the private network, messages are encrypted and decrypted during transfer.
----------
## Reference
- 

