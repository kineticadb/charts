

## Testing

Helm tests are included and they confirm connection to slapd.

```bash
helm install . --set test.enabled=true
helm test <RELEASE_NAME>
RUNNING: foolish-mouse-openldap-service-test-akmms
PASSED: foolish-mouse-openldap-service-test-akmms
```

It will confirm that we can do an ldapsearch with the default credentials

## Other useful commands
    
```bash
openldapPassword=$(kubectl -n gpudb get secrets openldap -o json | jq '.data.LDAP_ADMIN_PASSWORD' | tr -d '"' | base64 -d)
openldapPort=$(kubectl -n gpudb get cm openldap-env -o json| jq '.data.LDAP_PORT_NUMBER'| tr -d '"')
command="kubectl -n gpudb exec -it $(kubectl -n gpudb get pods -l app=openldap -o name) -- ldapsearch -x -H ldap://localhost:${openldapPort} -b dc=kinetica,dc=com -D "cn=admin,dc=kinetica,dc=com" -w ${openldapPassword}"
eval $command

# just the schema names
command3="kubectl -n gpudb exec -it $(kubectl -n gpudb get pods -l app=openldap -o name) -- ldapsearch -b "cn=schema,cn=config" -H ldapi:/// -LLL -Q -Y EXTERNAL dn"
eval $command3

# all schema dump
command2="kubectl -n gpudb exec -it $(kubectl -n gpudb get pods -l app=openldap -o name) -- ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=schema,cn=config objectClass=*"
eval $command2

# backends, schemas and modules.
command4="kubectl -n gpudb exec -it $(kubectl -n gpudb get pods -l app=openldap -o name) -- ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config"
eval $command4
```
