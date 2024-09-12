


docker run -it --name test-envornment-box -v ~/.kube/config:/work/.kube/config -e KUBECONFIG=/work/.kube/config -v ${HOME}:/root/ -v ${PWD}:/work -w /work --net host developerhelperhub/kub-terr-work-env-box

