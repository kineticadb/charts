---
hide:
  - navigation
tags:
  - Operations
  - Monitoring
---
# :material-text-box: Log Collection & Display

It is possible to forward/server the Kinetica on Kubernetes logs via an OpenTelemetry [OTEL] collector.

By default an OpenTelemetry Collector is deployed in the `kinetica-system` namespace as part of the Helm install of the
the kinetica-operators Helm chart along with a Kubernetes ConfigMap to configure this collector. The ConfigMap is in the
`kinetica-system` namespace and is called `otel-collector-conf`.

!!! note "Detailed `otel-collector-conf` setup"
    For more details on the Kinetica installed OTEL Collector please see [here](../Operations/otel.md).

There are many supported mechanisms to expose the logs here is one possibility: -

* `lokiexporter` - Exports data via HTTP to Loki.

!!! tip
    For a full list of supported OTEL exporters, including those for GrafanaCloud, AWS, Azure, Logz.io, Splunk 
    and many databases please
    see [here](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter)

## `lokiexporter` OTEL Collector Exporter

Exports data via HTTP to Loki.

```yaml title="Example Configuration"
exporters:
  loki:
    endpoint: https://loki.example.com:3100/loki/api/v1/push
    default_labels_enabled:
      exporter: false
      job: true
```

For full details on configuring the OTEL collector exporter `lokiexporter`
see [here](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/lokiexporter).

---
