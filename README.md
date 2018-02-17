# helm-k8s-varnish as front end swift cache
This repo includes the kubernetes yaml and helm yamls for deploying varnish cache for ObjectStorage Swift.
We have two secnarios which show you how to setup Varnish cache cluster to connect swift with SSL or without SSL cert at endpoint.
 * WithoutSSLforSwift
   * Client -> Varnish -> 8080(http) -> Swift
 * WithSSLforSwift
   * Client -> Vannish -> 443(https) -> Swift

You can find design idea and run instructions in subfolders.

Moreover, we provide your kubernetes yaml for spin up your own ObjectStorage Swift cluster ( All in One ) for unit test purpose
 * k8s-swift
