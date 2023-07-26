# How to create a Helm Release

After making changes to the Helm chart, you can create a new release by running the following command:

```bash
helm package kinetica-operators
helm repo index --url https://kineticadb.github.io/charts/ .
mv index.yaml docs/
mkdocs gh-deploy
```