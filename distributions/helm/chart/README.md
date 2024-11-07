# Ontotext Reconciliation Helm Charts

![Version: 1.0.0-SNAPSHOT](https://img.shields.io/badge/Version-1.0.0--SNAPSHOT-informational?style=flat-square)

## Overview

This is the official [Helm](https://helm.sh/) Chart for `Ontotext Reconciliation`. The aim of the chart is to simplify
deployments and management in [Kubernetes](https://kubernetes.io/) environments.

The current chart is a composition of few sub-charts, which are providing the base components and services needed for
setting up the Ontotext's implementation of the
[Reconciliation Service API](https://www.w3.org/community/reports/reconciliation/CG-FINAL-specs-0.2-20230410/).

## Quick Start

```bash
# Add Ontotext Helm Repository
helm repo add ontotext https://maven.ontotext.com/repository/helm-public/

# Install the Ontotext Reconciliation chart
helm install ontotext-reconciliation ontotext/ontotext-reconciliation
```

The chart is released and published in our own Public Helm Repository.

## Prerequisites

* [Kubernetes](https://kubernetes.io/) v1.26+
* [Helm](https://helm.sh/) v3.8+

### GraphDB License

In order to use the Enterprise Edition features of GraphDB, in particular the `Elasticsearch GraphDB Connector`, you
will need a GraphDB License.

If you already have one, you need to create a Secret object with it:

```bash
kubectl create secret generic graphdb-license --from-file graphdb.license=<license-file> --namespace <namespace>
```

where the `<namespace>` is the used namespace in the Kubernetes cluster and the `<license-file>` is the path to the
license file.

If you are using the different name for the secret, do not forget to update the `graphdb.license.existingSecret`
configuration in the `values.yaml` file.

For more details, you can refer to the official [GraphDB Helm Chart](https://github.com/Ontotext-AD/graphdb-helm).

## Deployment

### Versions Information

The table reflects the current state between the Helm Charts of the dependencies and the actual applications for the
latest release of the `Ontotext Reconciliation` chart:

| Dependencies  | Chart Version | Application Version |
|---------------|---------------|---------------------|
| Reconciliator | 1.0.0         | 1.0.0               |
| Index Manager | 1.0.0         | 1.0.0               |
| GraphDB       | 11.1.3        | 10.7.3              |
| Elasticsearch | 7.17.18       | 7.17.18             |

### Install

1. Add Ontotext's Public Helm Repository

   ```bash
   helm repo add ontotext https://maven.ontotext.com/repository/helm-public/
   ```

2. Install `Ontotext Reconciliation` chart

   ```bash
   helm install ontotext-reconciliation ontotext/ontotext-reconciliation
   ```

3. Upgrade `Ontotext Reconciliation` deployment

   ```bash
   helm upgrade --install ontotext-reconciliation ontotext/ontotext-reconciliation
   ```

Refer to [Configurations](#configurations) or [values.yaml](./values.yaml) for the available customization options.

### Uninstall

To uninstall `Ontotext Reconciliation`, use the following command:

```bash
helm uninstall ontotext-reconciliation
```

## Version Upgrades

The chart follows [Semantic Versioning](https://semver.org/) so any breaking changes will be released as MAJOR versions
of the chart.

Please, always check out the [MIGRATION-GUIDE](./MIGRATION-GUIDE.md), before upgrading to a new major version.

## Configurations

This section provides information about the configuration options for each of the component and resource. Most of the
components are pre-configured with default values.

However, there are some configurations without default values, which are required. Their values depend on the use case
in which the deployment is used, in particular the datasets that are used as sources for the Reconciliation API.

Make sure to read and understand, what each of the configurations listed below do and how it will change the behavior of
the system when changed.

### Values Overrides

Helm [values files](https://helm.sh/docs/chart_template_guide/values_files/) can be overridden in several ways.

You can either:

* use separate/additional `.yaml` file, which holds the overrides of the original `values.yaml` file 
  For example, you can install the current chart and also provide file with overridden values:

   ```bash
   helm install ontotext-reconciliation ontotext/ontotext-reconciliation --values overrides.yaml
   ```
* override specific value by passing it directly via `--set`:

   ```bash
   helm install ntotext-reconciliation ontotext/ontotext-reconciliation --set reconciliator.provision.customPreviewTemplates.enabled=true
   ```
### Networking

By default, the current chart comes with a default `Ingress`.

It can be disabled by switching `ingress.enabled` to `false`.

### Resources

Each component in the deployment is defined with default resource limits. The assumption is that the dataset that will
be used will be small. 
However, for production deployments it is obligatory to revise these resource limits and tune them for your environment.
You should consider common requirements like amount of data, users, expected traffic.

Look for `<component>.resources` blocks in the [values.yaml](values.yaml). During Helm's template rendering, these YAML
blocks are inserted in the Kubernetes pod configurations as pod resource limits.

See the `Kubernetes` documentation
[Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container)
about defining resource limits.

### Components

#### Reconciliator

##### Application Configurations

Below you can find the list of the application configurations, which are currently supported by the `Reconciliator`.
Each value can be overridden by setting a pair of key and value into the `values.yaml` (or the `.yaml` that overrides
it) for the `reconciliator.configurations` section.

| Key                                         | Default Value          | Description                                                                                                                                               |
|---------------------------------------------|------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| server.headers.Access-Control-Allow-Origin  | "*"                    | Spring Boot configuration, used to define allowed origins for the requests                                                                                |
| server.headers.Access-Control-Allow-Headers | "*"                    | Spring Boot configuration, used to define supported request headers                                                                                       |
| conciliator.extendData.querySampleSize      | 20                     | Controls the size of the sample for the `Data Extension` part of the Reconciliation Service API                                                           |
| conciliator.extendData.typeStrict           | "must"                 | Controls the Elasticsearch Boolean query conditions regarding the type of the entities                                                                    |
| conciliator.suggest.propertyDefaultLimit    | 10                     | Controls the default limit of the properties that are suggested by `Suggest` request                                                                      |
| conciliator.suggest.entityDefaultLimit      | 10                     | Controls the default limit of the entities that are suggested by `Suggest` request                                                                        |
| conciliator.suggest.typeDefaultLimit        | 10                     | Controls the default limit of the types that are suggested by `Suggest` request                                                                           |
| conciliator.cache.enabled                   | true                   | Toggles the cache capabilities of the application                                                                                                         |
| conciliator.cache.ttl                       | 3600                   | Controls the eviction time a cache entry                                                                                                                  |
| conciliator.cache.size                      | 256MB                  | Controls the size of the application cache. Value examples: `128kB`, `128MB`, `128GB`                                                                     |
| elastic.config.file                         | "/elastic-config.json" | Provides a path to the file containing the configuration mapping between the Elasticsearch indices and application. See the next section for more details |
| management.endpoints.web.exposure.include   | prometheus             | Spring Boot configuration, used to control the format of the statistics endpoints.                                                                        |
| management.health.solr.enabled              | false                  | Spring Boot configuration, which toggles the default health checks for Solr                                                                               |
| management.health.elasticsearch.enabled     | false                  | Spring Boot configuration, which toggles the default health checks for Elasticsearch                                                                      |
| logging.pattern.level                       | "%5p %X{X-Request-ID}" | Spring Boot configuration, controls the format of the logging messages                                                                                    |

> **NOTE**: The `Reconciliator` is a [Spring Boot](https://spring.io/projects/spring-boot) application, meaning that all
Spring configurations are also supported and can be passed on or overridden.

Example of changing the *root logging level* of the application:

```yaml
reconciliator:
  enabled: true
  configurations:
    logging.level.root: DEBUG
    # more application configurations
```

##### Reconciliation Config JSON

The file described in this section is arguably the most import one for the `Reconciliator` application. It provides
information for the `Elasticsearch` indices, what data is available, how it should be handled, the types of the
entities, etc.

Single configuration file can contain multiple index configuration objects (nodes). For each index configuration, the
`Reconciliator` application creates Reconciliation endpoints, according to the `Reconciliation Service API`
Specification.

The example below will result in creation of Reconciliation endpoints, where the context path is `organizations`. If we
assume the `Reconciliator` application is started locally, the available endpoints will be:

* `http://localhost:8080/organizations?query=...`
* `http://localhost:8080/organizations/suggest/property?prefix=...`
* etc...

```json
{
  "organizations": {
    "indexName": "organizations",
    "elasticUrl": "http://elastic:9200",
    "queryField": [
      "prefLabel",
      "altLabel"
   ],
    "nameField": "prefLabel",
    "searchFieldPhraseBoost": 1,
    "searchFieldPhraseSlop": 2,
    "searchFieldBoost": 1.2,
    "typeField": "type",
    "typeFieldBoost": 2,
    "types": [
      "http://www.wikidata.org/entity/Organization"
    ],
    "defaultType": "http://www.wikidata.org/entity/Organization",
    "propertiesBoost": {
      "country": 0.5
    },
    "preview": {
      "mode": "EXTERNAL",
      "urlTemplate": "https://wikidata.reconci.link/en/preview?id={{id}}",
      "idRegex": ".*/([^/]*)$"
    }
  }
}
```

Here is a list of the index configuration properties (fields) and their descriptions (for some of properties we are
using the example configuration, because the property is user defined):

> **NOTE**: Some of the listed fields are not present in the example configuration as they are optional and/or have
default fallback logic.

* `organizations`: (string) used as context path for the Reconciliation API. The usual value is the name of the
  Elasticsearch index, but it can be something else as well.
  * `indexName`: (string) the name of the Elasticsearch index, which should be used as data provider for the specific
    Reconciliation API.
  * `elasticUrl`: (string) URL of the Elasticsearch instance, which contains the index. This configuration allows the
    Reconciliator to work with multiple Elasticsearch instances.
  * `queryField`: (array) field(s) to use, when searching for the value in a column that is being reconciled.
    Additionally, the fields (properties) defined in it are used for the entity suggestion queries along with the `id`.
  * `nameField`: (string, optional) field to fetch the name (label) for reconciled IRIs. When not provided as name will
    be used the actual IRI.
  * `searchFieldPhraseBoost`: (float) boost for the match phrase query for the search field.
  * `searchFieldPhraseSlop`: (integer) slop for the match phrase query for the search field.
  * `searchFieldBoost`: (float, optional) boost for search field. Default is `1.0`.
  * `typeField`: (string) field to strict-match against the chosen type for the Reconciliation process.
  * `typeFieldBoost`: (float) boost for the type field query.
  * `types`: (array) IRIs of types the current service can reconcile.
  * `defaultType`: (string) the default type for the reconciliation that will be shown to the client.
  * `propertiesBoost`: (object, optional) custom boosts for each entity properties/characteristics. The properties are
    values from additional column that can be send at reconciliation time. The default boost for each property is `1.0`.
  * `propertiesType`: (object, optional) marks properties/fields as containing reconciled items (i.e. IRIs) This is used
    for adding new columns based on reconciled items. Properties that aren't listed will be treated as literals (string,
    number, date).
  * `template`: (string, optional) Elasticsearch query template to be used for fine-tuning the queries used for
    reconciliation process. The placeholders for the actual values are using `{{}}` double brackets, which are processed
    runtime.

    Example:
     ```json
     template: "{\"query\":{\"bool\":{\"should\":[{\"match\":{\"type\":\"{{type}}\"}},{\"match\":{\"prefLabel\":\"{{prefLabel}}\"}}]}},\"aggs\":{\"types_count\":{\"terms\":{\"field\":\"{{type}}\"}}}}"
     ```
  * `batchMode`: (boolean, optional) Toggles whether the Elasticsearch queries should be batch or not. The default is
    `true`.
  * `preview`: (object, optional) Provides details for the HTML template that should be rendered for Reconciliation
    Preview requests. Check the next section for more details.

##### Preview Templates

The `Reconciliation Configuration JSON` allows you to define a specific preview template, which will correspond to the
`Preview` requests of the `Reconciliation API`.

These templates are configured via specific field: `preview` and currently there are few supported modes:

* External

  The mode is expected to return an `HTML`, which will be rendered when there is a `Preview` request to the
  Reconciliation API.

  Example configuration:

   ```json
   {
     "preview": {
       "mode": "EXTERNAL",
       "urlTemplate": "https://wikidata.reconci.link/en/preview?id={{id}}",
       "idPrefix": "http://example.com/resource/",
       "idRegex": ".*/([^/]*)$",
       "cssQuery": "html body div img",
       "baseUrl": "https://wikidata.reconci.link"
     }
   }
   ```

  * `urlTemplate`: template for the external URL. Should contain `{{id}}`, which is to be replaced with the ID of the
    object to be previewed.
  * `idPrefix`: prefix which is to be removed from the `id` before being sent to the external service.
  * `idRegex` - if set the regex will be applied against the `id` and only the 1st group will be selected as `id` to be
    sent to the external service.
  * `cssTemplate`: could be used to return only a part of the HTML returned from the external  service. Internally
    [jsoup](https://jsoup.org/cookbook/extracting-data/selector-syntax) is used to parse and select from the HTML.
  * `baseUrl`: if set the collected page will get its base changed. This is used when the page contains relative URLs
    which would otherwise not work.

* Elastic

   This mode will extract the preview data from `Elasticsearch`. To generate the HTML page itself a template is used.
   Currently the template engine uses [Mustache](https://mustache.github.io/mustache.5.html). However, if there is a
   need for a [different engine](https://www.baeldung.com/spring-template-engines), it could be easily implemented.

   Example configuration:

   ```json
   {
     "preview": {
       "mode": "ELASTIC",
       "elasticUrl": "http://elastic:9982",
       "indexName": "organizations",
       "nameField": "prefLabel",
       "fields": [
         "prefLabel",
         "altLabel"
       ],
       "view": "organizations"
     }
   }
   ```

  * `elasticUrl`: location of the Elasticsearch host. Default value is `elasticUrl` property of the index configuration.
  * `indexName`: name of the Elasticsearch index. Default value is `indexName` property of the index configuration.
  * `nameField`: name field for the entity. Default value is `nameField` property of the index configuration.
  * `fields`: which field should be fetched from Elasticsearch. Corresponds to `_source` parameter in the Elasticsearc
    query. By default all fields are returned.
  * `view`: name of the template to be used. If not set a default template will be used. Check the next bullet point
    section for more details.

* Mustache Templates

  As mentioned the preview is divided into model and view. The model is extracted from elastic. A sample model from the
  configuration above is:

   ```json
   {
     "_id": "http://www.wikidata.org/entity/Q21466891",
     "_name": "Kenneth Coutts-Smith",
     "_properties": [
       {
         "name": "Kenneth Coutts-Smith"
       },
       {
         "gender": "male"
       }
     ],
     "_width": 400,
     "_height": 100,
     "gender": "male",
     "name": "Kenneth Coutts-Smith"
   }
   ```

   The special properties are the ones starting with `_`:

   * `_id`: id of the entity.
   * `_name`: value of the `preview.nameField`.
   * `_width`: width configured in the preview configuration.
   * `_height`: height configured in the preview configuration.
   * `_properties`: a convenient collection of the entity fields. They are ordered in the same way as in the
     `preview.fields` configuration. If `preview.fields` is not specified they are ordered alphabetically.

   The `name` and `gender` properties are extracted from Elasticsearch for the specific entity. Only they are collected
   as this only they are specified in the `preview.fields` setting.

   Below is the default `Mustache` template being used (at the time of writing the doc):

   ```html
   <html>
     <body>
       <h4><a href="{{_id}}" , target="_blank">{{_name}}</a></h4>
         <div style="height: {{_height}}; width: {{_width}}">
           <ul>
             {{#_properties}}
               <li><b>{{key}}</b>: {{value}}</li>
             {{/_properties}}
           </ul>
         </div>
      </body>
   </html>
   ```

   It produces the following example `HTML`:

   ```html
   <html>
     <body>
       <h4><a href="http://www.wikidata.org/entity/Q155004", target="_blank">Philippe of Belgium</a></h4>
         <div style="height: 100; width: 400">
           <ul>
             <li><b>name</b>: Philippe of Belgium</li>
               <li><b>gender</b>: male</li>
           </ul>
         </div>
      </body>
   </html>
   ```

   Custom templates could be used as well. In order to do so you should add in the following format:
   `templates/<template_name>.mustache`. The template should be placed in `templates` folder and should be
   using `.mustache` extension. 
   Once you have the template in place, it is enough to just specify the `<template_name>` (without the folder and
   extension) in `preview.view` setting.

##### Chart Values

> **NOTE**: this is a direct copy of the table for the `Reconciliator` Helm Chart. It provides the default values that
are currently set for the sub-chart.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| configuration."service.port" | string | `"8080"` |  |
| extraAnnotations | object | `{}` |  |
| extraConfig | object | `{}` |  |
| extraContainers | list | `[]` |  |
| extraEnvFrom | list | `[]` |  |
| extraEnvFromConfigmap | list | `[]` |  |
| extraEnvFromSecret | list | `[]` |  |
| extraEnvs | list | `[]` |  |
| extraInitContainers | list | `[]` |  |
| extraLabels | object | `{}` |  |
| extraSecretConfig | object | `{}` |  |
| extraVolumeClaimTemplates | list | `[]` |  |
| extraVolumeMounts | list | `[]` |  |
| extraVolumes | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| global.imagePullSecrets | string | `nil` |  |
| global.imageRegistry | string | `nil` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.pullSecrets | list | `[]` |  |
| image.registry | string | `"docker-registry.ontotext.com"` |  |
| image.repository | string | `"ontotext/reconciliation/reconciliator"` |  |
| image.tag | string | `""` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"ontorecon-reconciliator.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.labels | object | `{}` |  |
| ingress.tls | list | `[]` |  |
| javaOpts | string | `""` |  |
| livenessProbe.failureThreshold | int | `30` |  |
| livenessProbe.tcpSocket.port | string | `"http"` |  |
| livenessProbe.timeoutSeconds | int | `30` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| pdb.create | bool | `false` |  |
| pdb.maxUnavailable | string | `nil` |  |
| pdb.minAvailable | int | `1` |  |
| persistence.enabled | bool | `false` |  |
| persistence.volumeClaimTemplateSpec.accessModes[0] | string | `"ReadWriteOnce"` |  |
| persistence.volumeClaimTemplateSpec.resources.requests.storage | string | `"2Gi"` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| provision.customPreviewTemplates.configmaps[0].file | string | `"default.mustache"` |  |
| provision.customPreviewTemplates.configmaps[0].name | string | `"reconciliator-default-preview-template"` |  |
| provision.customPreviewTemplates.enabled | bool | `false` |  |
| provision.customPreviewTemplates.mountPath | string | `"/opt/reconciliator/preview/templates"` |  |
| provision.elasticsearch.configmap | string | `"reconciliator-elastic-config"` |  |
| provision.elasticsearch.filename | string | `"elastic-config.json"` |  |
| provision.elasticsearch.mountPath | string | `"/opt/reconciliator"` |  |
| readinessProbe.httpGet.path | string | `"/protocol"` |  |
| readinessProbe.httpGet.port | string | `"http"` |  |
| resources | object | `{}` |  |
| secretConfiguration | object | `{}` |  |
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1000` |  |
| service.annotations | object | `{}` |  |
| service.enabled | bool | `true` |  |
| service.headless.annotations | object | `{}` |  |
| service.headless.labels | object | `{}` |  |
| service.labels | object | `{}` |  |
| service.nodePort | string | `""` |  |
| service.port | int | `8080` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| startupProbe.failureThreshold | int | `10` |  |
| startupProbe.httpGet.path | string | `"/protocol"` |  |
| startupProbe.httpGet.port | string | `"http"` |  |
| startupProbe.initialDelaySeconds | int | `5` |  |
| startupProbe.periodSeconds | int | `3` |  |
| terminationGracePeriodSeconds | int | `120` |  |
| tolerations | list | `[]` |  |
| updateStrategy.type | string | `"RollingUpdate"` |  |

#### Index Manager

##### Application Configurations

Below you can find the list of the application configurations, which are currently supported by the `Index Manager`.
Each value can be overridden by setting a pair of key and value into the `values.yaml` (or the `.yaml` that overrides
it) for the `index_manager.configurations` section.

| Key                         | Default Value          | Description                                                                                                          |
|-----------------------------|------------------------|----------------------------------------------------------------------------------------------------------------------|
| elasticsearch.host          | "http://elastic:9200"  | The address of the `Elasticsearch` instance, which indices will be managed by the application                        |
| elasticsearch.updateCronJob | "0 0 0 * * *"          | Controls the frequency of the indices updates. The value should be valid Spring Boot Cron Expression                 |
| graphdb.host                | "http://graphdb:7200"  | The address of the `GraphDB` instance, where the connectors will be created                                          |
| graphdb.repo                | "wdtruthy"             | The identifier of the GraphDB Repository, where the connectors will be created                                       |
| graphdb.username            | ""                     | Username for connection to the `GraphDB`, if the security is enabled                                                 |
| graphdb.password            | ""                     | Password for connection to the `GraphDB`, if the security is enabled                                                 |
| index.sourceDirectory       | "/opt/create_indices"  | Path to the directory, where the connector query files should be retrieved                                           |
| index.outputDirectory       | "/opt/index_data"      | Path to the output directory, where the application will store indices status and additional static RDF data related |
| logging.pattern.level       | "%5p %X{X-Request-ID}" | Spring Boot configuration, controls the format of the logging messages                                               |

> **NOTE**: The `Index Manager` is a [Spring Boot](https://spring.io/projects/spring-boot) application, meaning that all
Spring configurations are also supported and can be passed on or overridden.

##### Elasticsearch Connectors and SPARQL Queries

* Elasticsearch Connector(s)

`GraphDB` supports creation of various Connectors via `SPARQL Query`. This allows the `Index Manager` to automate the
processes of creation and/or update of the `Elasticsearch GraphDB Connector(s)`.

The queries are provided as files, which the `Index Manager` reads and executes against the `GraphDB SPARQL Endpoint`.
`index.sourceDirectory` configuration provides the path to the directory, where the files are stored. There could be
multiple files, which will result in creation of multiple Connectors.

Please check the official documentation for the
[Elasticsearch GraphDB Connector](https://graphdb.ontotext.com/documentation/10.7/elasticsearch-graphdb-connector.html),
which provides in-dept details on how to write configurations, what are the supported properties and additional
configurations, etc.

The `Index Manager` relies on few minor customizations to the Connector Configurations. There are two custom
placeholders, which are processed during runtime.

1. `{INDEX}` - postfix (suffix) of the index identifier. It is used during connector/index update procedure to allow
   smooth transition to new (updated) index without downtime of the `Reconciliation` functionalities.

2. `{DATA_TTL}` - optional, placeholder for a file containing RDF data from which to create the connector. Basically
   creates a connector whose data will come from an RDF file on the file system instead of data contained in the
   repository. 
   This placeholder is also used to load the data, generated from the query files described in the next bullet point.

Example:

```
PREFIX : <http://www.ontotext.com/connectors/elasticsearch#>
PREFIX inst: <http://www.ontotext.com/connectors/elasticsearch/instance#>

INSERT DATA {
	inst:organizations_{INDEX} :createConnector '''
    {
      "fields": [
        {
            "propertyChain": ["$self"],
            "fieldName": "id",
            "multivalued": false,
            "ignoreInvalidValues": true
        },
        {
          "fieldName": "prefLabel",
          "propertyChain": [
            "http://www.w3.org/2004/02/skos/core#prefLabel"
          ],
          "indexed": true,
          "stored": true,
          "analyzed": true,
          "multivalued": true,
          "ignoreInvalidValues": false,
          "fielddata": false,
          "array": false,
          "objectFields": []
        },
        {
          "fieldName": "altLabel",
          "propertyChain": [
            "http://www.w3.org/2004/02/skos/core#altLabel"
          ],
          "indexed": true,
          "stored": true,
          "analyzed": true,
          "multivalued": true,
          "ignoreInvalidValues": false,
          "fielddata": false,
          "array": false,
          "objectFields": []
        },
        {
          "fieldName": "type",
          "propertyChain": [
            "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
          ],
          "indexed": true,
          "stored": true,
          "analyzed": false,
          "multivalued": true,
          "ignoreInvalidValues": false,
          "fielddata": false,
          "array": false
        }
      ],
      "languages": [],
      "types": ["http://www.wikidata.org/entity/Organization"],
      "readonly": true,
      "detectFields": false,
      "importGraph": false,
      "importFile": "{DATA_TTL}",
      "elasticsearchNode": "http://elastic:9200",
      "elasticsearchClusterSniff": true,
      "manageIndex": true,
      "manageMapping": true,
      "bulkUpdateBatchSize": 5000,
      "bulkUpdateRequestSize": 5242880
    }
''' .
}
```

* SPARQL CONSTRUCT Queries

Optionally, you can add `SPARQL CONSTRUCT` queries for each of the indices that the Manager will create. The queries
should also be provided as files. They should be placed within directory named `queries` and their extension should be
`.sparql`. 
You can provide multiple queries, which will result in a single RDF file, which will be loaded as data for the related
index.

Simple example of the file structure:

```
./
+-- /opt
|   +-- /index-manager
|   |   +-- /example-index
|   |   |   +-- example-index.sparql
|   |   |   +-- /queries
|   |   |   |   +-- example-construct-1-query.sparql
|   |   |   |   +-- example-construct-2-query.sparql
```

##### Chart Values

> **NOTE**: this is a direct copy of the table for the `Index Manager` Helm Chart. It provides the default values that
are currently set for the sub-chart.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| configuration."elasticsearch.host" | string | `"http://elastic:9200"` |  |
| configuration."elasticsearch.updateCronJob" | string | `"0 0 0 * * *"` |  |
| configuration."graphdb.host" | string | `"http://graphdb:7200"` |  |
| configuration."graphdb.repo" | string | `"wdtruthy"` |  |
| extraAnnotations | object | `{}` |  |
| extraConfig | object | `{}` |  |
| extraContainers | list | `[]` |  |
| extraEnvFrom | list | `[]` |  |
| extraEnvFromConfigmap | list | `[]` |  |
| extraEnvFromSecret | list | `[]` |  |
| extraEnvs | list | `[]` |  |
| extraInitContainers | list | `[]` |  |
| extraLabels | object | `{}` |  |
| extraSecretConfig | object | `{}` |  |
| extraVolumeClaimTemplates | list | `[]` |  |
| extraVolumeMounts | list | `[]` |  |
| extraVolumes | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| global.imagePullSecrets | string | `nil` |  |
| global.imageRegistry | string | `nil` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.pullSecrets | list | `[]` |  |
| image.registry | string | `"docker-registry.ontotext.com"` |  |
| image.repository | string | `"ontotext/reconciliation/index-manager"` |  |
| image.tag | string | `""` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"ontorecon-index-manager.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.labels | object | `{}` |  |
| ingress.tls | list | `[]` |  |
| javaOpts | string | `""` |  |
| livenessProbe.failureThreshold | int | `30` |  |
| livenessProbe.tcpSocket.port | string | `"http"` |  |
| livenessProbe.timeoutSeconds | int | `30` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| pdb.create | bool | `false` |  |
| pdb.maxUnavailable | string | `nil` |  |
| pdb.minAvailable | int | `1` |  |
| persistence.enabled | bool | `false` |  |
| persistence.volumeClaimTemplateSpec.accessModes[0] | string | `"ReadWriteOnce"` |  |
| persistence.volumeClaimTemplateSpec.resources.requests.storage | string | `"2Gi"` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| provision.index.output.enabled | bool | `false` |  |
| provision.index.output.mountPath | string | `"/opt/index_data"` |  |
| provision.index.source.configmaps | list | `[]` |  |
| provision.index.source.mountPath | string | `"/opt/create_indices"` |  |
| readinessProbe.httpGet.path | string | `"/protocol"` |  |
| readinessProbe.httpGet.port | string | `"http"` |  |
| resources | object | `{}` |  |
| secretConfiguration | object | `{}` |  |
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1000` |  |
| service.annotations | object | `{}` |  |
| service.enabled | bool | `true` |  |
| service.headless.annotations | object | `{}` |  |
| service.headless.labels | object | `{}` |  |
| service.labels | object | `{}` |  |
| service.nodePort | string | `""` |  |
| service.port | int | `8080` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| startupProbe.failureThreshold | int | `10` |  |
| startupProbe.httpGet.path | string | `"/protocol"` |  |
| startupProbe.httpGet.port | string | `"http"` |  |
| startupProbe.initialDelaySeconds | int | `5` |  |
| startupProbe.periodSeconds | int | `3` |  |
| terminationGracePeriodSeconds | int | `120` |  |
| tolerations | list | `[]` |  |
| updateStrategy.type | string | `"RollingUpdate"` |  |

#### GraphDB

For the full list of configurations, values and general details on the component, please refer to the official
[GraphDB Helm Chart](https://github.com/Ontotext-AD/graphdb-helm).

#### Elasticsearch

For the full list of configurations, values and general details on the component, please refer to the official
[Elasticsearch Helm Chart](https://github.com/elastic/helm-charts).

> **NOTE**: The current Elasticsearch dependency uses the charts for `7.x.x` version. Migration to a newer version is on
the roadmap. However, it uses different chart
[Elastic Cloud on Kubernetes (ECK)](https://github.com/elastic/cloud-on-k8s), which will require additional migration
effort, if you want to keep the existing indices, created while using the older version.

## Examples (TBD)

The directory [examples](./examples/) contains different example setups and configurations for the current chart.

Check them out and follow the `README` files in order to spin up the environment.

## Use Cases

We have a separate GitHub repository containing
[Reconciliation Use Cases](https://github.com/Ontotext-AD/reconciliation-use-cases). 

There are several sets of specific data and resources for use cases, where the Reconciliation Service is useful.
Each use case provides the configurations and data in order to setup the `Ontotext Reconciliation` over it.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Ontotext | <reconciliation@ontotext.com> | <https://www.ontotext.com> |

## License

Refer to the [LICENSE](../../../LICENSE) files.
