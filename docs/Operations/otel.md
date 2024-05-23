---
hide:
  - navigation
tags:
  - Configuration
  - Operations
  - Monitoring
---
# OTEL Integration for Metric & Log Distribution

!!! note title "Helm installed OTEL Collector"
    By default an OpenTelemetry Collector is deployed in the `kinetica-system` namespace as part of the Helm install of the
    the kinetica-operators Helm chart along with a Kubernetes ConfigMap to configure this collector. The ConfigMap is in the
    `kinetica-system` namespace and is called `otel-collector-conf`.

The Kinetica DB Operators send information to an OpenTelemetry collector. There are two choices

* install an OpenTelemetry collector with the Kinetica Operators Helm chart
* use an existing provisioned OpenTelemetry collector within the Kubernetes Cluster


## Install an OpenTelemetry collector with the Kinetica Operators Helm chart

To enable the Kinetica Operators Helm Chart to deploy an instance of the OpenTelemetry collector into
the `kinetica-system` namespace you need to set the following configuration in the helm values: -

### TODO add Helm Config Example Here

A ConfigMap containing the OTEL collector configuration will be generated so that the necessary
`receivers` and `processors` sections are correctly setup for a Kinetica DB Cluster.

This configuration will: -

receivers:

* configure a `syslog` receiver which will receive logs from the Kinetica DB pod.
* configure a `prometheus` receiver/scraper which will collect metrics form the Kinetica DB.
* configure an `otlp` receiver which will receive trace spans from the Kinetica Operators (Optional).
* configure the `hostmetrics` collection of host load & memory usage (Optional).
* configure the `k8s_events` collection of Kubernetes Events for the Kinetica namespaces (Optional).

processors:

* configure attribute processing to set some useful values
* configure resource processing to set some useful values

### `syslog` Configuration

The OpenTelemetry `syslogreceiver` documentation can be found
[*here*](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/syslogreceiver).

#### OTEL Receivers Configuration

```yaml
receivers:  
  syslog:  
    tcp:  
      listen_address: "0.0.0.0:9601"  
    protocol: rfc5424  
```

#### OTEL Service Configuration

!!! tip
    In order to batch pushes of log data upstream you can use the following
    `processors section` in the OTEL configuration.

    ```yaml
    processors:  
      batch:  
    ```

```yaml
service:   
  pipelines:
    logs:
      receivers: [syslog]
      processors: [resourcedetection, attributes, resource, batch]
      exporters: ... # Requires configuring for your environment
```

### `otlp` Configuration

The default configuration opens both the OTEL gRPC & HTTP listeners.

#### OTEL Receivers Configuration

```yaml
receivers:
  otlp:  
    protocols:  
      grpc:  
        endpoint: "0.0.0.0:4317"  
      http:  
        endpoint: "0.0.0.0:4318" 
```

#### OTEL Service Configuration

!!! tip
    In order to batch pushes of trace data upstream you can use the following
    `processors section` in the OTEL configuration.
    
    ```yaml
    processors:  
      batch:  
    ```

```yaml
service:
  traces:
    receivers: [otlp]
    processors: [batch]
    exporters:  ... # Requires configuring for your environment
```

!!! warning "exporters"
    The `exporters` will need to be manually configured to your specific environment
    e.g. forwarding logs/metrics to Grafana, Azure Monitor, AWS etc.

    Otherwise the data will 'disappear into the ether' and not be relayed upstream.


### `hostmetrics` Configuration (Optional)

The Host Metrics receiver generates metrics about the host system scraped from various sources. 
This is intended to be used when the collector is deployed as an agent.

The OpenTelemetry `hostmetrics` documentation can be found
[*here*](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/hostmetricsreceiver).


#### OTEL Receivers Configuration

!!! note "hostmetricsreceiver"
    The OTEL `hostmetricsreceiver`requires that the running OTEL collector is the 'contrib' version.

```yaml
receivers:
  hostmetrics:  
    # https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/hostmetricsreceiver  
    scrapers:  
      load:  
      memory: 
```

??? tip "Grafana"
    the attributes and resource processing enables finer grained selection using
    Grafana queries.

### `k8s_events` Configuration (Optional)

The kubernetes Events receiver collects events from the Kubernetes API server.
It collects all the new or updated events that come in from the specified namespaces. Below we are collecting
events from the two default Kinetica namespaces: -

```yaml
receivers:
  k8s_events:  
    namespaces: [kinetica-system, gpudb]  
```

The OpenTelemetry `k8seventsreceiver` documentation can be found
[*here*](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/k8seventsreceiver).

## Use an existing provisioned OpenTelemetry Collector

#### Coming Soon

---
