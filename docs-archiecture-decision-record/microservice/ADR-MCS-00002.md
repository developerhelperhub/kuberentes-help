# ADR-MCS-00002

## Requirement

We have to use secure authentication and authorisation our application

Version: 1.0.0

----------
## Design Consideration 1
****- We can use the Oauth2 protocol in our application for authentication and authorisation of application
- We can increase the secure communication between client and server
- It provided access token and refresh token 
- Reduce the life time of token to avoid the risk
- It provides different grand type based on our authentication use cases such as Password, Authorise Code, Implicit, Client Credential
- In the microservice architecture protect the secure access our services and authenticate and authorise, best protocol is Oauth2. We can use the each microservice can give specific scope access and role permission based on user role and group
----------
## Reference
- REF000000008
- REF000000009

