# k8s-volume-injector
Mount volumes to workloads using MutatingWebhookConfiguration. Based on: https://github.com/tumblr/k8s-sidecar-injector


## Requirements
You must have cert-manager installed.

## How to use it
```bash
# Install tumblr/k8s-sidecar-injector & webhook
export VERSION="main"
curl -s https://raw.githubusercontent.com/atorrescogollo/k8s-volume-injector/${VERSION}/deploy/install.sh | bash
```

```bash
# Check installation
$ kubectl -n k8s-volume-injector get mutatingwebhookconfigurations,svc,deploy
NAME                                                                            WEBHOOKS   AGE
mutatingwebhookconfiguration.admissionregistration.k8s.io/k8s-volume-injector   1          1h

NAME                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/k8s-volume-injector   ClusterIP   10.233.62.149   <none>        443/TCP   1h

NAME                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/k8s-volume-injector   1/1     1            1           1h

# Apply an example (demo1)
kubectl apply -f examples/demo1.yaml
```
```bash
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
