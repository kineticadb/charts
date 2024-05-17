# :simple-prometheus: MetricsCollection & Display

It is possible to forward/server the Kinetica on Kubernetes metrics via an OpenTelemetry [OTEL] collector. 

By default an OpenTeleletry Collector is deployed in the `kinetica-system` namespace as part of the Helm install of the
the kinetica-operators Helm chart along with a Kubernetes ConfigMap to configure this collector. The ConfigMap is in the 
`kinetica-system` namespace and is called `otel-collector-conf`.

There are many supported mechanisms to expose the metrics here are a few possibilities: -

* `prometheusremotewriteexporter` - Prometheus Remote Write Exporter sends OpenTelemetry metrics to Prometheus remote write compatible backends.
* `prometheusexporter` - allows the metrics to be scraped by a Prometheus server

!!! tip
    For a full list of supported OTEL exporters, including those for AWS, Azure and many databases please 
    see [here](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter)

## `prometheusremotewriteexporter` Prometheus OTEL Remote Write Exporter

!!! quote "prometheusremotewriteexporter OTEL Exporter"
    Prometheus Remote Write Exporter sends OpenTelemetry metrics to Prometheus remote write compatible backends 
    such as Cortex, Mimir, and Thanos. By default, this exporter requires TLS and offers queued retry capabilities.

!!! warning
    Non-cumulative monotonic, histogram, and summary OTLP metrics are dropped by this exporter.

```yaml title="Example Configuration"
exporters:
  prometheusremotewrite:
    endpoint: "https://my-cortex:7900/api/v1/push"
    external_labels:
      label_name1: label_value1
      label_name2: label_value2
```

For full details on configuring the OTEL collector exporter `prometheusremotewriteexporter` 
see [here](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/prometheusremotewriteexporter).

## `prometheusexporter` Prometheus OTEL Exporter

Exports data in the Prometheus format, which allows it to be scraped by a Prometheus server.

```yaml title="Example Configuration"
exporters:
  prometheus:
    endpoint: "1.2.3.4:1234"
    tls:
      ca_file: "/path/to/ca.pem"
      cert_file: "/path/to/cert.pem"
      key_file: "/path/to/key.pem"
    namespace: test-space
    const_labels:
      label1: value1
      "another label": spaced value
    send_timestamps: true
    metric_expiration: 180m
    enable_open_metrics: true
    add_metric_suffixes: false
    resource_to_telemetry_conversion:
      enabled: true
```

For full details on configuring the OTEL collector exporter `prometheusexporter`
see [here](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/prometheusexporter).
---
