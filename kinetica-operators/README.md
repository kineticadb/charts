
# Trying Kinetica

Pull the kinetica-operators oci chart and prepare for install

```bash
helm pull oci://registry.harbor.kinetica.com/kinetica-k8s/kinetica-operators --version 0.1.0
mkdir charts
mv kinetica-operators kinetica-operators-0.1.0.tgz charts/
```

If you are on a local machine which is not having a domain name, you add the following entry to your /etc/hosts file or equivalent.

```text
127.0.0.1 local.kinetica
```

## k3s (k3s.io)

### Install k3s 1.25

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik  --node-name kinetica-master --token 12345" K3S_KUBECONFIG_OUTPUT=~/.kube/config_k3s K3S_KUBECONFIG_MODE=644 INSTALL_K3S_VERSION=v1.25.12+k3s1 sh -
```

### Install k3s 1.26

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik  --node-name kinetica-master --token 12345" K3S_KUBECONFIG_OUTPUT=~/.kube/config_k3s K3S_KUBECONFIG_MODE=644 INSTALL_K3S_VERSION=v1.26.12+k3s1 sh -
```

### Install k3s 1.27

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik  --node-name kinetica-master --token 12345" K3S_KUBECONFIG_OUTPUT=~/.kube/config_k3s K3S_KUBECONFIG_MODE=644 INSTALL_K3S_VERSION=v1.27.9+k3s1 sh -
```

### Install k3s 1.28

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik  --node-name kinetica-master --token 12345" K3S_KUBECONFIG_OUTPUT=~/.kube/config_k3s K3S_KUBECONFIG_MODE=644 INSTALL_K3S_VERSION=v1.28.6+k3s2 sh -
```

### Install k3s 1.29

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik  --node-name kinetica-master --token 12345" K3S_KUBECONFIG_OUTPUT=~/.kube/config_k3s K3S_KUBECONFIG_MODE=644 INSTALL_K3S_VERSION=v1.29.1+k3s2 sh -
```


#### K3s -Install kinetica-operators including a sample db to try out

Review the values file charts/kinetica-operators/values.onPrem.k3s.yaml. This is trying to install the operators and a simple db with workbench installation for a non production try out.

As you can see it is trying to create an ingress pointing towards local.kinetica. If you have a domain pointing to your machine, replace it with the correct domain name.

##### K3s - Install the kinetica-operators chart

```bash
helm -n kinetica-system install kinetica-operators charts/kinetica-operators/ --create-namespace --values charts/kinetica-operators/values.onPrem.k3s.yaml
```

You should be able to access the workbench at [http://local.kinetica](http://local.kinetica)

Username as per the values file mentioned above is kadmin and password is Kinetica1234!

## Uninstall k3s

```bash
/usr/local/bin/k3s-uninstall.sh
```

## Kind (kubernetes in docker kind.sigs.k8s.io)

### Create Kind Cluster 1.25

```bash
kind create cluster --config charts/kinetica-operators/kind.yaml  --image kindest/node:v1.25.16@sha256:9d0a62b55d4fe1e262953be8d406689b947668626a357b5f9d0cfbddbebbc727
```

### Create Kind Cluster 1.26

```bash
kind create cluster --config charts/kinetica-operators/kind.yaml  --image kindest/node:v1.26.13@sha256:15ae92d507b7d4aec6e8920d358fc63d3b980493db191d7327541fbaaed1f789
```

### Create Kind Cluster 1.27

```bash
kind create cluster --config charts/kinetica-operators/kind.yaml  --image kindest/node:v1.27.10@sha256:3700c811144e24a6c6181065265f69b9bf0b437c45741017182d7c82b908918f
```

### Create Kind Cluster 1.28

```bash
kind create cluster --config charts/kinetica-operators/kind.yaml  --image kindest/node:v1.28.6@sha256:b7e1cf6b2b729f604133c667a6be8aab6f4dde5bb042c1891ae248d9154f665b
```

### Create Kind Cluster 1.29

```bash
kind create cluster --config charts/kinetica-operators/kind.yaml
``` 

#### Kind - Install kinetica-operators including a sample db to try out

Review the values file charts/kinetica-operators/values.onPrem.kind.yaml. This is trying to install the operators and a simple db with workbench installation for a non production try out.

As you can see it is trying to create an ingress pointing towards local.kinetica. If you have a domain pointing to your machine, replace it with the correct domain name.


##### Kind - Install the kinetica-operators chart


```bash
helm -n kinetica-system install kinetica-operators charts/kinetica-operators/ --create-namespace --values charts/kinetica-operators/values.onPrem.kind.yaml
```

You should be able to access the workbench at [http://local.kinetica](http://local.kinetica)

Username as per the values file mentioned above is kadmin and password is Kinetica1234!

