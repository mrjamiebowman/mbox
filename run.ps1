docker run -it --rm --name mbox --network host --hostname mbox -v mbox:/mbox -v work:/work -v $env:userprofile/.kube:/root/.kube -v //var/run/docker.sock:/var/run/docker.sock mrjamiebowman/mbox /bin/bash