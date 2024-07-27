# ADR-MCS-00001

## Requirement

We should capable to manage the authentication and authorisation in our application. It should provides secure authentication and authorisation capability. We should have capable manager user, role, groups, multi tenant. This authentication service should have capability to provide connect other IdP provider.

Version: 1.0.0

----------
## Design Consideration 1
****- We can use the Keycloak open source authentication and authroisation service our application
- It provides central dashboard where we can managing following functionality in high level
    - Multi tenant (Relam)
    - User
    - Group
    - Role
    - Scope
    - Identity Broker
    - Federation 
- We can easy integrate with multiple framework
- It provided the Oauth2 protocol for authentication and authorisation
## Design Consideration 2
- Keycloak can integrate with Prometheus server for monitoring the metrics
- Prometheus server collect the metrics from Keycloak and can be easily identify the issue if any happen
----------
## Design Consideration 3
- Keycloak can integrate Kong API integration for authorisation to validate the user
----------
## Design Consideration 4
- For adding the more security, we need to authorise each microservice based on the token
- This helps internal communication between microservices will be protected. This helps to reduce the middle attack / data manipulation

**Concern**

- Performance will be degraded, normal application authentication we can validate the authentication and authorisation at API gateway level, no need to validate the microservice. In this approach 
----------


## Architecture
![](https://paper-attachments.dropboxusercontent.com/s_357B5F05564D8EBD6AB709BCADE38913B57AF37EAAE74DB3CFE21D631D085E65_1721455498384_Microservice-Authentication+Authorization.drawio.png)


 

## Reference
- REF000000007
- https://www.jerney.io/secure-apis-kong-keycloak-1/

