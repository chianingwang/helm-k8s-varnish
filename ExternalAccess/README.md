# Idea

Client -> ingest -> service -> pods

# Deployment
```
$ kubectl get ing
NAME      HOSTS                 ADDRESS   PORTS     AGE
helm      helm.swiftstack.org             80, 443   10s

$ kubectl get svc
NAME                                TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)         AGE
kubernetes                          ClusterIP   10.96.0.1      <none>        443/TCP         17d
toned-pika-helm-varnish-ssl-swift   NodePort    10.111.137.7   <none>        443:32340/TCP   52m
```

### Double check
To make sure we are using port `32340`
```
$ netstat -ntlp
(Not all processes could be identified, non-owned process info
 will not be shown, you would have to be root to see it all.)
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      -
tcp        0      0 0.0.0.0:6783            0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.1:6784          0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.1:10248         0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.1:10249         0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.1:2379          0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.1:10251         0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.1:2380          0.0.0.0:*               LISTEN      -
tcp        0      0 127.0.0.1:10252         0.0.0.0:*               LISTEN      -
tcp6       0      0 :::22                   :::*                    LISTEN      -
tcp6       0      0 :::6781                 :::*                    LISTEN      -
tcp6       0      0 :::6782                 :::*                    LISTEN      -
tcp6       0      0 :::10250                :::*                    LISTEN      -
tcp6       0      0 :::6443                 :::*                    LISTEN      -
tcp6       0      0 :::10255                :::*                    LISTEN      -
tcp6       0      0 :::10256                :::*                    LISTEN      -
tcp6       0      0 :::32340                :::*                    LISTEN      -
```

# Unit Testing
Testing is only allow using auth token and storagne endpoing currently, we need to study how to attatching port when geting storage endpoing via python swift client.
```
$ swift -A https://helm.swiftstack.org:32340/auth/v1.0 -U ss -K ss auth
export OS_STORAGE_URL=https://helm.swiftstack.org/v1/AUTH_ss
export OS_AUTH_TOKEN=AUTH_tk8927ee147649479fba710959e95b6681

$ swift --os-auth-token AUTH_tk8927ee147649479fba710959e95b6681 --os-storage-url https://helm.swiftstack.org:32340/v1/AUTH_ss stat -v
                             StorageURL: https://helm.swiftstack.org:32340/v1/AUTH_ss
                             Auth Token: AUTH_tk8927ee147649479fba710959e95b6681
                                Account: AUTH_ss
                             Containers: 2
                                Objects: 6
                                  Bytes: 352393
Containers in policy "standard-replica": 2
   Objects in policy "standard-replica": 6
     Bytes in policy "standard-replica": 352393
                      Meta Temp-Url-Key: 87743c66-2ec3-4cac-8569-f763315a057a
                 X-Openstack-Request-Id: tx28ed26a6f5e84705ac54f-005a91e6e1
                                    Via: 1.1 varnish-v4
                          Accept-Ranges: bytes
                                 Server: nginx/1.10.3 (Ubuntu)
                                    Age: 0
                             Connection: keep-alive
                              X-Varnish: 30
                            X-Timestamp: 1517420818.76217
                             X-Trans-Id: tx28ed26a6f5e84705ac54f-005a91e6e1
                           Content-Type: text/plain; charset=utf-8
```
