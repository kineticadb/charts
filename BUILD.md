# How to create a Helm Release

After making changes to the Helm chart, you can create a new release by running the following command:

```bash
earthly --push +local-helm-package --VERSION=1.2.3
earthly --push +publish
```

You can also just re-index the helm chart repo and repush with...

```bash
earthly --push local-helm-index
earthly --push +publish
```
