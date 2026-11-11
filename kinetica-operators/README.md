
# Trying Kinetica

Pull the kinetica-operators and prepare for install

```bash
helm repo add kinetica-operators https://kineticadb.github.io/charts
helm repo update
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
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik  --node-name kinetica-master --token 12345" K3S_KUBECONFIG_OUTPUT=~/.kube/config_k3s K3S_KUBECONFIG_MODE=644 INSTALL_K3S_VERSION=v1.29.2+k3s1 sh -
```


#### K3s -Install kinetica-operators including a sample db to try out

Review the values file charts/kinetica-operators/values.onPrem.k3s.yaml. This is trying to install the operators and a simple db with workbench installation for a non production try out.

As you can see it is trying to create an ingress pointing towards local.kinetica. If you have a domain pointing to your machine, replace it with the correct domain name.

##### K3s - Install the kinetica-operators chart

```bash
helm -n kinetica-system install kinetica-operators charts/kinetica-operators/ --create-namespace --values charts/kinetica-operators/values.onPrem.k3s.yaml
```

##### K3s - Install the kinetica-operators chart (GPU Capable Machine)

If you wish to try out the GPU capabilities, you can use the following values file, provided you are in a nvidia gpu capable machine.

```bash
helm -n kinetica-system install kinetica-operators charts/kinetica-operators/ --create-namespace --values charts/kinetica-operators/values.onPrem.k3s.gpu.yaml
```

You should be able to access the workbench at [http://local.kinetica](http://local.kinetica)

Admin credentials are provided via a pre-created Kubernetes secret (see `dbAdminUser.adminUserSecretName` in values).

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

Admin credentials are provided via a pre-created Kubernetes secret (see `dbAdminUser.adminUserSecretName` in values).

## Kafka HA ring (two or more installs)

Two or more `kinetica-operators` installs can form a Kinetica HA ring over a customer-managed Kafka. The
members may be separate Kubernetes clusters or separate namespaces of one cluster. Set
`kineticacluster.gpudbCluster.config.ha` on every member (see the commented example in `values.yaml`).

Before the first install of every member, pre-create these Secrets in the DB namespace with **identical**
values on all members (the operator never overwrites an existing one, and refuses to generate a random
value while `config.ha.enable` is true):

```bash
kubectl -n gpudb create secret generic <clusterName>-internal-password-secret --from-literal=PASSWORD='<shared admin password>'
kubectl -n gpudb create secret generic <clusterName>-crypto-secret --from-literal=SECRET_KEY='<shared key>'
```

Alternatively reference existing Secrets (for example synced by an external secret store) with
`config.ha.internalPasswordSecretName` and `config.ha.cryptoSecretName`; their values seed the fixed-name
Secrets above on the first reconcile. Kafka SASL credentials go in a Secret with `username` and
`password` keys referenced by `config.ha.kafka.credentialsSecretName`. Values files never carry passwords or keys.

What the operator renders when HA is enabled:

- `enable_ha = true` and `host0.ha_address` in gpudb.conf. The address is `config.network.HAAddress` if
  set, else the load balancer hostname of `<clusterName>-ha-service` when `config.ha.service.type` is
  `LoadBalancer` (the reconcile waits for it), else the in-cluster headless rank-0 Service name.
- `host0.public_address` when `config.network.publicAddress` is set (`scheme://host[:port]`). The ring
  and SDK auto-discovery learn rank 0 as `<publicAddress>:8082/gpudb-0`, so it must reach rank 0's httpd
  from outside: the `<clusterName>-ha-service` load balancer, or the site's CB Proxy (Circuit Breaker Proxy,
  `doorman` in values) listening on 8082. Unset, the pod IP is advertised and only clients given every member's URL can fail over.
- `rank<N>.public_url` as `<config.network.publicURLBase>/gpudb-<N>` when set, so multi-head ingest also
  goes through the per-site proxy. Only set it when `<publicURLBase>/gpudb-<N>` routes to rank N.
- `gpudb_ha_conf.json` in the Secret `<clusterName>-ha-config`, mounted at
  `/opt/gpudb/core/etc/gpudb_ha_conf.json`.
- `<clusterName>-ha-service` exposing rank 0's HA port 9191 and head port 8082 to the other members.
  Use `config.ha.service.type: LoadBalancer` (with internal load balancer annotations) when the members are
  in different Kubernetes clusters; the default `ClusterIP` is enough inside one cluster.
- With `doorman.install` and `doorman.ha.enabled`, the site's CB Proxy also serves the bare `/gpudb-N`
  paths members advertise (set `doorman.listener.port: 8082` and point `config.network.publicAddress`
  and `publicURLBase` at it). With `doorman.ha.peer.host` set it fails rank routes over to that peer when
  the local rank is unreachable, after probing that the peer reports `drained`. The SDK discovery calls
  (`/show/system/status`, `/show/system/properties`) are never failed over: answered by the peer they would make
  this address look like the peer cluster and stall auto-discovering clients. The probe's
  credentials come from the Secret named by `doorman.ha.readyCheck.secretName` (key `auth`, value
  `user:password`). Without `doorman.ha` the CB Proxy renders exactly as before (hold only).
  `doorman.service.type: LoadBalancer` gives the proxy its own external address.

### Two-site example

Two Kubernetes clusters (any mix of EKS, AKS, on-prem), one Kafka both can reach, and one helm install per
site. Each site is reached at its own name, served by that site's CB Proxy on port 8082.

1. In **both** clusters, create the Secrets in the DB namespace. The first two must hold the same values
   on both sites:

   ```bash
   kubectl -n gpudb create secret generic <clusterName>-internal-password-secret --from-literal=PASSWORD='<shared admin password>'
   kubectl -n gpudb create secret generic <clusterName>-crypto-secret --from-literal=SECRET_KEY='<shared key>'
   kubectl -n gpudb create secret generic cb-proxy-probe-auth --from-literal=auth='admin:<shared admin password>'
   kubectl -n gpudb create secret tls site-tls --cert=<site certificate> --key=<site key>
   # only when Kafka needs credentials:
   kubectl -n gpudb create secret generic ring-kafka-creds --from-literal=username='<user>' --from-literal=password='<password>'
   ```

2. Install site A with these values on top of the usual ones for the platform. Site B uses the same file
   with `site-a` and `site-b` swapped in `kineticacluster.name`, `workbench.clusterRef.name`,
   `publicAddress`, `publicURLBase`, the `url` entry and `doorman.ha.peer.host`; the `clusters` list keeps
   the same order.

   ```yaml
   kineticacluster:
     name: site-a
     gpudbCluster:
       config:
         ha:
           enable: true
           clusters:
             - name: site-a
             - name: site-b
               url: https://site-b.example.com:8082/gpudb-0
           kafka:
             brokers:
               - host: kafka.example.com
                 port: 9092
             # securityProtocol: SASL_SSL
             # saslMechanism: SCRAM-SHA-512
             # credentialsSecretName: ring-kafka-creds
           service:
             type: LoadBalancer            # plus the cloud's internal load balancer annotations
         network:
           publicAddress: https://site-a.example.com
           publicURLBase: https://site-a.example.com:8082
   workbench:
     clusterRef:
       name: site-a
   doorman:
     install: true
     listener:
       port: 8082
       tlsSecretName: site-tls
     service:
       type: LoadBalancer                  # plus the cloud's load balancer annotations
     ha:
       enabled: true
       peer:
         host: site-b.example.com
         port: 8082
         transport: HTTPS
       readyCheck:
         secretName: cb-proxy-probe-auth
   ```

   Certificates from a private CA: the operator and the CB Proxy must trust the CA that signed the other
   site's certificate. If the `site-tls` Secret carries a `ca.crt` entry (cert-manager adds one) and one
   CA signed both sites, nothing more is needed. Otherwise create a ConfigMap with the CA in the DB
   namespace and name it in `kineticacluster.gpudbCluster.config.ha.caConfigMapName`:

   ```bash
   kubectl -n gpudb create configmap ring-ca --from-file=ca.crt=<CA certificate>
   ```

   Certificates from a public authority need neither. Client applications must trust the CA as well.

3. Point DNS for `site-a.example.com` and `site-b.example.com` at the load balancer of each site's
   `<clusterName>-doorman` Service.

4. Check: `kubectl -n gpudb get kineticacluster <clusterName> -o jsonpath='{.status.ha}'` shows a
   `lastLinkTime` on both sites once each can reach the other's address, and a table created on one site
   appears on the other.

Ring rules: `config.ha.clusters` must list the same members in the same order on every install and
include the install's own `clusterName`; `haRingName` is required; the ring size cannot change while
clusters run; Kafka must be reachable from every member and is a write-consistency dependency (writes
during a Kafka outage are applied locally and not replicated).

Peer linking: each member's `url` is the base URL of that member's rank-0 API as reachable from this
operator (for example `http://<its ha-service address>:9191`, or its site URL ending in `/gpudb-0`).
The operator fetches every member's system status with the shared admin password, writes the status
files into its own gpudb pods and refreshes HA, and repeats that whenever a pod restarts or a member's
addresses change; the result is in `status.ha` of the KineticaCluster. A member without a `url` (other
than the install itself) is not linked. The operator Role needs `pods/exec` for this.

