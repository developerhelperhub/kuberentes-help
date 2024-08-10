Run the development environment in Docker for developers working on Kubernetes projects. This setup allows developers to work in a consistent, isolated environment that mimics the production setup, facilitating easier testing and integration.

Build docker image
```shell
docker build -f developerhelperhub/kub-terr-work-env-box .
```

Push docker image to docker hub 
```shell
docker push developerhelperhub/kub-terr-work-env-box
```

Run docker container sh mode
```shell
docker run -it --name local-envornment-box -v ${HOME}/root/ -v ${PWD}/work -w /work --net host developerhelperhub/kub-terr-work-env-box sh
```

Verify the service 
```shell
docker info
kubectl version
kind version
terraform --version
helm version
git --version
```