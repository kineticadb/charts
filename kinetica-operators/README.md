
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
  this address look like the peer cluster and stall auto-discovering clients. While the local database is down
  the proxy answers them from its last healthy copy instead (the `holdShield` behaviour, always on once a peer
  is set), so clients can keep using, and new clients can connect to, this address. One gap remains: for about
  a second while a database shuts down it still answers, with the error `Query planner is not running` or
  `System shutting down`. SDK clients that know the ring retry on the other site by themselves; a client pinned to
  one address with failover off must retry that statement itself. The probe's
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

2. Install site A with these values (also shipped as `examples/ha-site-with-cb-proxy.yaml`) on top of the
   usual ones for the platform. Site B uses the same file
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

Changing HA settings: the database reads `config.ha` only when it starts. A change on a running cluster is
accepted and recorded as a `HAConfigChanged` warning event on the KineticaCluster, and takes effect at the
next database restart; the operator never restarts the database for it. To restart one site (do the sites
one at a time, the other one serves meanwhile):

```yaml
apiVersion: app.kinetica.com/v1
kind: KineticaClusterAdmin
metadata:
  name: <cluster>-restart-1      # a new name for each restart
  namespace: <cluster namespace>
spec:
  kineticaClusterName: <cluster>
  regenerateDBConfig:
    restart: true
```


### Enabling HA on installs that already exist

Step 1 of the two-site example only fits new installs. An install made without HA already has
`<clusterName>-internal-password-secret` and `<clusterName>-crypto-secret`, each with a value generated for
that install alone, and the operator never overwrites them. Two such installs must be brought to the same
two values before they are joined. Until they are:

- different admin passwords: `status.ha` shows the other member `linked: false` with
  `HTTP 401 Insufficient credentials`;
- same password, different crypto keys: every member shows `linked: true`, yet nothing replicates and
  nothing is logged.

The crypto key encrypts the credentials stored in the database (`CREATE CREDENTIAL`). A credential stored
under one key cannot be read, altered or dropped under another, so never invent a new key for a site that
has credentials. Pick one site as the source of both values and change only the other site:

1. On the site that will change, drop its credentials (`DROP CREDENTIAL`), and note how to recreate them.
2. Set its admin password to the source site's, in the database first and then in the Secret, so the
   operator is never locked out:

   ```bash
   # as admin on the site that changes
   #   ALTER USER admin SET PASSWORD '<source site admin password>'
   kubectl -n gpudb create secret generic <clusterName>-internal-password-secret \
     --from-literal=PASSWORD='<source site admin password>' --dry-run=client -o yaml | kubectl apply -f -
   ```

3. Put the source site's key in its crypto Secret the same way (`<clusterName>-crypto-secret`, key
   `SECRET_KEY`).
4. Upgrade both installs with the HA values. The first time HA is switched on the operator restarts the
   database; if the site that changed was not restarted by that, restart it with a
   `KineticaClusterAdmin` as shown above, because the database reads both Secrets only when it starts.
5. Recreate the dropped credentials, on one site only.

Once the sites are linked, the admin password is replicated like any other user change: changing it with
SQL on one site changes it on every site, and every site's `<clusterName>-internal-password-secret` must
then be updated to the new value.

Tables that existed before the ring was formed stay on their own site; only changes made after both sites
are linked are replicated.

### Users and roles in a ring

Users, roles, grants and default schemas made with SQL on one site are replicated to the others, like any
other change.

`KineticaUser`, `KineticaRole` and `KineticaGrant` objects depend on the authentication type:

- `authentication.type: Internal`: apply them on one site only. The login works on every site, and
  deleting the object removes it everywhere.
- `authentication.type: LDAP` (the default, with the chart's own OpenLDAP): the password is stored in the
  directory of the site the object was applied to, so the login works only there. Apply the same objects
  on every site.

### How clients connect

Every site accepts reads and writes; nothing is primary or standby. What a client does when its site goes
down depends on the client and on whether the site has a CB Proxy.

- **With the CB Proxy (the two-site example).** Any client can be given one site's address. While that
  site's database is down its proxy serves the requests from the other site, so clients that cannot fail
  over (plain REST callers, tools pinned to one URL, JDBC with `DisableFailover=1`) keep working, and new
  clients can still start against that address.
- **Without the CB Proxy** (`doorman.install: false`). Expose each site's `<clusterName>-ha-service` on
  port 8082 (`config.ha.service.type: LoadBalancer`), set `publicAddress`, `publicURLBase` and the other
  member's `url` to that address, and give every client all site addresses
  (`http://site-a.example.com:8082/gpudb-0,http://site-b.example.com:8082/gpudb-0`); the values are
  shipped as `examples/ha-site-without-cb-proxy.yaml`. The Kinetica SDKs
  and the JDBC driver then fail over by themselves. A client given only one address learns the others
  while that site is up, but cannot start while it is down, and a client with failover switched off fails
  until its site returns. The service speaks plain HTTP: put TLS in front of it, or keep the CB Proxy.
  Always use port 8082; with LDAP authentication never expose port 9191 to clients.
- **One writing site.** To have a single site take all writes, give clients only that site's address
  (with the CB Proxy), or list it first (without). This is a convention the clients keep, not something
  the ring enforces.

### Internal authentication and the httpd front end

With `kineticacluster.authentication.type: Internal` the database checks logins itself, and its httpd
front end (port 8082) only routes `/gpudb-N` to the ranks. The CB Proxy and ring members addressed on 8082
need it; nothing else does. An Internal install that uses neither can switch it off:

```yaml
kineticacluster:
  gpudbCluster:
    config:
      network:
        enableHTTPDProxy: false
```
