!!! tip "FQDN or Local Access"
    By default we create an ingress pointing towards `local.kinetica`. 
    If you have a domain pointing to your machine, replace/set the FQDN in the `values.yaml` 
    with the correct domain name or by adding `--set `.
    
    If you are on a local machine which is not having a domain name, 
    you add the following entry to your `/etc/hosts` file or equivalent.
    
    ```shell title="Configure local access - /etc/hosts"
    127.0.0.1  local.kinetica
    ```
