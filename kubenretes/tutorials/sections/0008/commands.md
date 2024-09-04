

Terraform
* https://registry.terraform.io/providers/kyma-incubator/kind/latest/docs/resources/cluster
* https://devopscube.com/jenkins-build-agents-kubernetes/

https://www.jenkins.io/doc/book/installing/kubernetes/#setup-jenkins-on-kubernetes
https://plugins.jenkins.io/kubernetes/
https://www.jenkins.io/doc/book/platform-information/support-policy-java/
https://www.jenkins.io/doc/book/managing/nodes/

https://blog.thecloudside.com/docker-in-docker-with-jenkins-pod-on-kubernetes-f2b9877936f2

docker login should before push

curl -u admin:11ce29d4ae55b5b2341a63877d30175128 -o agent.jar http://localhost/jnlpJars/agent.jar

docker run -d --name jenkins-agent -e JENKINS_SECRET=admin -e JENKINS_NAME=admin developerhelperhub/graalvm-jenkins-agent


docker run --rm -it --entrypoint /bin/bash developerhelperhub/graalvm-jenkins-agent

docker run --rm -it -e JENKINS_SECRET=11ce29d4ae55b5b2341a63877d30175128 -e JENKINS_NAME=graalvm-jenkins-agent -e JENKINS_URL=http://10.96.102.61:8080/ developerhelperhub/graalvm-jenkins-agent


java -jar /usr/local/bin/jenkins-agent.jar -secret $(JENKINS_SECRET) -name $(JENKINS_NAME) -url http://jenkins:8080

java -jar /usr/local/bin/jenkins-agent.jar -secret 11ce29d4ae55b5b2341a63877d30175128 -name graalvm-jenkins-agent -url http://10.96.102.61:8080



kubectl delete -n jenkins pods --field-selector status.phase=Failed
kubectl get -n jenkins pods --field-selector status.phase=Running
kubectl delete -n jenkins pods --field-selector status.phase!=Running

docker network inspect bridge
"Gateway": "172.17.0.1"

kubectl delete -n devops pod graalvm-22-muslib-maven-pod-builder
kubectl apply -n devops -f maven-repo-pv-pvc.yaml
kubectl get -n devops pv
kubectl get -n devops pvc

kubectl -n devops create configmap maven-settings --from-file=settings.xml
kubectl -n devops delete configmap maven-settings

kubectl -n devops create secret generic maven-credentials --from-file=settings-security.xml
kubectl -n devops delete secret maven-credentials
kubectl -n devops get secret

kubectl apply -n devops -f graalvm-22-muslib-maven-jenkins-agent-template.yaml

kubectl -n devops exec -it graalvm-22-muslib-maven-jenkins-agent-template -c builder -- sh

du -sh /root/.m2

kubectl -n jenkins exec -it graalvm-22-muslib-maven-jenkins-agent-template -c docker -- sh

kubectl delete -n devops -f graalvm-22-muslib-maven-jenkins-agent-template.yaml

31/ 32 

docker ps
echo $DOCKER_HOST

kubectl delete -n jenkins -f graalvm-22-muslib-maven-pod-builder
kubectl delete -n jenkins -f maven-repo-pv-pvc.yaml


docker network inspect bridge

microdnf install git-all
git clone https://github.com/developerhelperhub/spring-boot-startup-performance.git -b main