# k8s-sidecar-injector-poc
Mount volumes to workloads using MutatingWebhookConfiguration. Based on: https://github.com/tumblr/k8s-sidecar-injector


## Requirements
You must have cert-manager installed.

## How to use it
```bash
# Install tumblr/k8s-sidecar-injector & webhook
export VERSION="main"
curl -s https://raw.githubusercontent.com/atorrescogollo/k8s-volume-injector/${VERSION}/deploy/install.sh | bash
```

### Check installation
```bash
$ kubectl -n k8s-volume-injector get mutatingwebhookconfigurations k8s-volume-injector
NAME                  WEBHOOKS   AGE
k8s-volume-injector   1          4m49s

$ kubectl -n k8s-volume-injector get all
NAME                                       READY   STATUS    RESTARTS   AGE
pod/k8s-volume-injector-595b896796-fp8bc   1/1     Running   0          5m12s

NAME                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/k8s-volume-injector   ClusterIP   10.233.49.141   <none>        443/TCP   5m12s

NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/k8s-volume-injector   1/1     1            1           5m12s

NAME                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/k8s-volume-injector-595b896796   1         1         1       5m12s
```
```bash
# Apply an example (demo1)
$ kubectl apply -f https://raw.githubusercontent.com/atorrescogollo/k8s-volume-injector/main/examples/demo1.yaml

# Check if the webhook has work (mounts /etc/ssl/certs from node)
$ kubectl -n k8s-volume-injector-demo1 get po demo1 -o json | jq '.spec.volumes[]|select(.name=="etc-ssl-certs")'
{
  "hostPath": {
    "path": "/etc/ssl/certs/",
    "type": ""
  },
  "name": "etc-ssl-certs"
}
```

## How to uninstall
```bash
kubectl -n k8s-volume-injector delete \
  mutatingwebhookconfigurations/k8s-volume-injector \
  service/k8s-volume-injector \
  deployment.apps/k8s-volume-injector \
  issuers.cert-manager.io/k8s-volume-injector \
  certificates.cert-manager.io/k8s-volume-injector \
  namespace/k8s-volume-injector
```
