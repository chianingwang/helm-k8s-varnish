# Abstract 
This solution is for demo purpose and usually provides cache for swift with cert, only with `https`

In this work we use k8s and helm for deployment
 * k8s (kubernetes)
 * helm

In this work , the container includes
 * nginx w/ reverse proxy with ssl to port 80
 * varnish from port 80 to port 8080
 * stunnel from port 8080 to swift endpoint with ssl , port 443

# Idea 
```
  Client -> SSL(443) ->
               Ngnix   |
            <- (80)  <-
           |  Varnish
           -> (8080) ->
              Stunnel  |
                        -> SSL (443) Swift Endpoint
```

# Instruction and Steps
## Build `varnishsslswift` Dcoker Image
```
$ cd helm-k8s-varnish/WithoutSSLforSwift/Dockerfile
$ sudo docker build -t="varnishswift:1.1" .
or 
$ sudo docker build -t="varnishswift:<your prefer version, e.g 1.1 or dev, latest ... >" .
```

### PS: You might need to change for your usecase
Since architecture design varnish in container will connect to local with port 8080, this the endpoint connect will from stunnel.
#### Dockerfile/varnish/default.vcl --> /etc/varnish/default.vcl
```
# Default backend definition. Set this to point to your content server.
backend default {
    .host = "127.0.0.1";
    .port = "8080";
}
```
#### Dockerfile/stunnel/stunnel.conf --> /etc/stunnel/stunnel.conf
connect to `<swift cluster endpoint FQDN>:<port>`
```
accept = 8080
connect = johnny.xxx.org:443 
```

## Create varnish cluster via `k8s` 
```
$ cd ..
$ kubectl create -f k8s-varnish-ssl-swift/k8s-varnish-ssl-swift.yaml
```

### Check varnish cluster result in `k8s`
```
$ kubectl get pods
NAME                   READY     STATUS    RESTARTS   AGE
paco-test-pod          1/1       Running   0          1d
varnishssl-ctl-5h9qn   1/1       Running   0          15m
varnishssl-ctl-twbg7   1/1       Running   0          15m

$ kubectl describe pods varnishssl-ctl-5h9qn
Name:           varnishssl-ctl-5h9qn
Namespace:      default
Node:           helm/192.168.22.200
Start Time:     Fri, 16 Feb 2018 18:24:03 +0000
Labels:         app=varnishssl-ctl
Annotations:    <none>
Status:         Running
IP:             10.32.0.53
Controlled By:  ReplicationController/varnishssl-ctl
Containers:
  varnishswift:
    Container ID:   docker://d40de6a29c4de31a97592e61ab50fe4a6074c06be687de667267308d63e75e44
    Image:          varnishswift:1.1
    Image ID:       docker://sha256:19002b4096f1ada602435180747e323166e45dfa4facf838ce61acc45f1fd71f
    Ports:          443/TCP, 80/TCP
    State:          Running
      Started:      Fri, 16 Feb 2018 18:24:04 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-sqcdh (ro)
Conditions:
  Type           Status
  Initialized    True
  Ready          True
  PodScheduled   True
Volumes:
  default-token-sqcdh:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-sqcdh
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason                 Age   From               Message
  ----    ------                 ----  ----               -------
  Normal  Scheduled              16m   default-scheduler  Successfully assigned varnishssl-ctl-5h9qn to helm
  Normal  SuccessfulMountVolume  16m   kubelet, helm      MountVolume.SetUp succeeded for volume "default-token-sqcdh"
  Normal  Pulled                 16m   kubelet, helm      Container image "varnishswift:1.1" already present on machine
  Normal  Created                16m   kubelet, helm      Created container
  Normal  Started                16m   kubelet, helm      Started container

$ kubectl get svc
NAME                TYPE        CLUSTER-IP      EXTERNAL-IP      PORT(S)                        AGE
kubernetes          ClusterIP   10.96.0.1       <none>           443/TCP                        9d
paco-test-service   NodePort    10.105.191.43   192.168.22.200   8080:32334/TCP,443:30173/TCP   1d
varnishssl-svc      NodePort    10.111.137.8    <none>           443:31492/TCP                  16m

$ kubectl describe svc varnishssl-svc
Name:                     varnishssl-svc
Namespace:                default
Labels:                   app=varnishssl
Annotations:              <none>
Selector:                 app=varnishssl-ctl
Type:                     NodePort
IP:                       10.111.137.8
Port:                     https  443/TCP
TargetPort:               443/TCP
NodePort:                 https  31492/TCP
Endpoints:                10.32.0.53:443,10.32.0.54:443
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

### `k8s scale down` demo
```
$ kubectl get pods
NAME                                             READY     STATUS    RESTARTS   AGE
paco-test-pod                                    1/1       Running   0          1d
varnishssl-ctl-5h9qn                             1/1       Running   0          34m
varnishssl-ctl-twbg7                             1/1       Running   0          34m

$ kubectl get rc
NAME             DESIRED   CURRENT   READY     AGE
varnishssl-ctl   2         2         2         34m

$ kubectl scale --replicas=1 rc/varnishssl-ctl
replicationcontroller "varnishssl-ctl" scaled

$ kubectl get rc
NAME             DESIRED   CURRENT   READY     AGE
varnishssl-ctl   1         1         1         35m

$ kubectl get pods
NAME                                             READY     STATUS        RESTARTS   AGE
paco-test-pod                                    1/1       Running       0          1d
quiet-newt-helm-varnish-swift-6b5bf9c44b-rtkv4   1/1       Running       0          8m
varnishssl-ctl-5h9qn                             1/1       Running       0          36m
varnishssl-ctl-twbg7                             1/1       Terminating   0          36m

PS: you can see one pod is Terminating now.
```

### Delete varnish cluster in `k8s`
```
$ kubectl delete -f k8s-varnish-swift/k8s-varnish-swift.yaml
service "varnishssl-svc" deleted
replicationcontroller "varnishssl-ctl" deleted
```

## Create varnish cluster via `helm`
```
$ cd ..
$ helm install ./helm-varnish-ssl-swift
NAME:   quiet-newt
LAST DEPLOYED: Fri Feb 16 18:51:06 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Service
NAME                           TYPE      CLUSTER-IP    EXTERNAL-IP  PORT(S)        AGE
quiet-newt-helm-varnish-swift  NodePort  10.111.137.7  <none>       443:30484/TCP  0s

==> v1beta2/Deployment
NAME                           DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
quiet-newt-helm-varnish-swift  1        1        1           0          0s


NOTES:
1. Get the application URL by running these commands:
  export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services quiet-newt-helm-varnish-swift)
  export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:$NODE_PORT
```

### Check varnish cluster result in `helm <k8s>`
```
$ kubectl get pods
NAME                                             READY     STATUS    RESTARTS   AGE
paco-test-pod                                    1/1       Running   0          1d
quiet-newt-helm-varnish-swift-6b5bf9c44b-rtkv4   1/1       Running   0          18s

$ kubectl describe pod quiet-newt-helm-varnish-swift-6b5bf9c44b-rtkv4
Name:           quiet-newt-helm-varnish-swift-6b5bf9c44b-rtkv4
Namespace:      default
Node:           helm/192.168.22.200
Start Time:     Fri, 16 Feb 2018 18:51:06 +0000
Labels:         app=helm-varnish-swift
                pod-template-hash=2616957006
                release=quiet-newt
Conditions:
Annotations:    <none>
Status:         Running
IP:             10.32.0.55
Controlled By:  ReplicaSet/quiet-newt-helm-varnish-swift-6b5bf9c44b
Containers:
  helm-varnish-swift:
    Container ID:   docker://29ae82bd71847f884fd8cb556e927e10ca1e7afde66ca5827faee6d7a9b92485
    Image:          varnishswift:1.1
    Image ID:       docker://sha256:19002b4096f1ada602435180747e323166e45dfa4facf838ce61acc45f1fd71f
    Ports:          80/TCP, 443/TCP
    State:          Running
      Started:      Fri, 16 Feb 2018 18:51:07 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-sqcdh (ro)
Conditions:
  Type           Status
  Initialized    True
  Ready          True
  PodScheduled   True
Volumes:
  default-token-sqcdh:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-sqcdh
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason                 Age   From               Message
  ----    ------                 ----  ----               -------
  Normal  Scheduled              47s   default-scheduler  Successfully assigned quiet-newt-helm-varnish-swift-6b5bf9c44b-rtkv4 to helm
  Normal  SuccessfulMountVolume  47s   kubelet, helm      MountVolume.SetUp succeeded for volume "default-token-sqcdh"
  Normal  Pulled                 46s   kubelet, helm      Container image "varnishswift:1.1" already present on machine
  Normal  Created                46s   kubelet, helm      Created container
  Normal  Started                46s   kubelet, helm      Started container

$ kubectl get svc
NAME                            TYPE        CLUSTER-IP      EXTERNAL-IP      PORT(S)                        AGE
kubernetes                      ClusterIP   10.96.0.1       <none>           443/TCP                        9d
paco-test-service               NodePort    10.105.191.43   192.168.22.200   8080:32334/TCP,443:30173/TCP   1d
quiet-newt-helm-varnish-swift   NodePort    10.111.137.7    <none>           443:30484/TCP                  58s

$ kubectl describe svc quiet-newt-helm-varnish-swift
Name:                     quiet-newt-helm-varnish-swift
Namespace:                default
Labels:                   app=helm-varnish-swift
                          chart=helm-varnish-swift-0.1.0
                          heritage=Tiller
                          release=quiet-newt
Annotations:              <none>
Selector:                 app=helm-varnish-swift,release=quiet-newt
Type:                     NodePort
IP:                       10.111.137.7
Port:                     https  443/TCP
TargetPort:               https/TCP
NodePort:                 https  30484/TCP
Endpoints:                10.32.0.55:443
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

### `helm scale up` demo
```
$ helm list
NAME      	REVISION	UPDATED                 	STATUS  	CHART                   	NAMESPACE
quiet-newt	1       	Fri Feb 16 18:51:06 2018	DEPLOYED	helm-varnish-swift-0.1.0	default

$ helm upgrade --set replicaCount=2 quiet-newt ./helm-varnish-swift
Release "quiet-newt" has been upgraded. Happy Helming!
LAST DEPLOYED: Fri Feb 16 19:03:26 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Service
NAME                           TYPE      CLUSTER-IP    EXTERNAL-IP  PORT(S)        AGE
quiet-newt-helm-varnish-swift  NodePort  10.111.137.7  <none>       443:30484/TCP  12m

==> v1beta2/Deployment
NAME                           DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
quiet-newt-helm-varnish-swift  2        2        2           1          12m


NOTES:
1. Get the application URL by running these commands:
  export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services quiet-newt-helm-varnish-swift)
  export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:$NODE_PORT

PS: see desired = 2 but since just scale up, available = 1 still

$ kubectl get pods
NAME                                             READY     STATUS    RESTARTS   AGE
paco-test-pod                                    1/1       Running   0          1d
quiet-newt-helm-varnish-swift-6b5bf9c44b-qw2xp   1/1       Running   0          1m
quiet-newt-helm-varnish-swift-6b5bf9c44b-rtkv4   1/1       Running   0          13m
```

### Delete varnish cluster in `helm`
```
$ helm ls
NAME      	REVISION	UPDATED                 	STATUS  	CHART                   	NAMESPACE
quiet-newt	2       	Fri Feb 16 19:03:26 2018	DEPLOYED	helm-varnish-swift-0.1.0	default

$ helm delete quiet-newt
release "quiet-newt" deleted
```

## Unit Test via `python-swiftclient`
```
Quick setup /etc/hosts for mapping clusterIP with DNS name 
$ cat /etc/hosts
192.168.22.200	helm.xxx.org	helm
10.32.0.53	s1.xxx.org	s1
10.32.0.54	s2.xxx.org	s2
10.111.137.7	test.xxx.org	test
10.111.137.8	test1.xxx.org	test1

# for helm we use clusterIP: 10.111.137.7
$ swift -A https://test.xxx.org/auth/v1.0 -U test:tester -K testing stat -v testcontainer setup.sh
                   URL: https://test.xxx.org/v1/AUTH_test/testcontainer/setup.sh
            Auth Token: AUTH_tk543375228e3d43d9b2b18bcf8c3b5c8c
               Account: AUTH_test
             Container: testcontainer
                Object: setup.sh
          Content Type: text/x-sh
        Content Length: 223
         Last Modified: Thu, 08 Feb 2018 01:59:27 GMT
                  ETag: 5e8a43f26839644d8a7847ee580344e2
            Meta Mtime: 1518027888.341155
                   Via: 1.1 varnish-v4
         Accept-Ranges: bytes
                   Age: 0
                Server: nginx/1.10.3 (Ubuntu)
            Connection: keep-alive
             X-Varnish: 32770
           X-Timestamp: 1518055166.33102
            X-Trans-Id: txd2817f5af51a492f82658-005a872883
X-Openstack-Request-Id: txd2817f5af51a492f82658-005a872883

# for k8s we use clusterIP: 10.111.137.8
$ swift -A https://test1.xxx.org/auth/v1.0 -U test:tester -K testing stat -v testcontainer setup.sh
                   URL: https://test1.xxx.org/v1/AUTH_test/testcontainer/setup.sh
            Auth Token: AUTH_tk543375228e3d43d9b2b18bcf8c3b5c8c
               Account: AUTH_test
             Container: testcontainer
                Object: setup.sh
          Content Type: text/x-sh
        Content Length: 223
         Last Modified: Thu, 08 Feb 2018 01:59:27 GMT
                  ETag: 5e8a43f26839644d8a7847ee580344e2
            Meta Mtime: 1518027888.341155
                   Via: 1.1 varnish-v4
         Accept-Ranges: bytes
                   Age: 0
                Server: nginx/1.10.3 (Ubuntu)
            Connection: keep-alive
             X-Varnish: 18
           X-Timestamp: 1518055166.33102
            X-Trans-Id: tx3adf453c15c04698b5af0-005a872624
X-Openstack-Request-Id: tx3adf453c15c04698b5af0-005a872624

PS: Age:0 is the varnish cache age

```

