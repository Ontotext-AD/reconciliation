# Ontotext Reconciliation Docker

## Overview

Current directory contains `Docker Compose` resources and configurations for for `Ontotext Reconciliation`. The main
goal is to provide documentation and examples on how to setup the Reconciliation services over specific set(s) of data.

The [docker-compose.yaml](./docker-compose.yaml) contains the base setup of services and components needed for setting
up the ntotext's implementation of the
[Reconciliation Service API](https://www.w3.org/community/reports/reconciliation/CG-FINAL-specs-0.2-20230410/).

## Quick Start

```bash
docker compose -f docker-compose.yaml up -d
```

> **NOTE**: Depending on the permissions given to `docker`, it may be required to use `sudo`. Primary required in order
to create additional resources in the mounted directories.

> **NOTE**: If you use the compose file as is, it will setup example repository and use queries to build up index for
the reconciliation. We recommend updating the compose file or use it just as example reference in order to setup the
services for your own data by following the documentation.

## Prerequisites

* [Docker](https://docs.docker.com/engine/install/)
* [Docker Compose](https://docs.docker.com/compose/install/)

### GraphDB License

In order to use the Enterprise Edition features of GraphDB, in particular the `Elasticsearch GraphDB Connector`, you
will need a GraphDB License.

If you already have one and use the current repository structure, replace the
[graphdb.license](./resources/graphdb/graphdb.license) file.

Alternatively, you can update the path to the license file (the name as well) in the compose file. Check the `volumes`
section for `graphdb` service.

## Deployment

### Versions Information

The table provides version information for the services used in the current compose file.

| Service       | Version |
|---------------|---------|
| Reconciliator | 1.0.0   |
| Index Manager | 1.0.0   |
| GraphDB       | 10.7.3  |
| Elasticsearch | 7.17.18 |

### Install

To start up the services using `Docker Compose`, use the following command:

```bash
docker compose -f docker-compose.yaml up -d
```

where the `-f` flag refers to the compose file that you want to use. If it is in another directory, you need to provide
relative path to it.

The `-d` flag is used to run the container in Detached mode, effectively running them in the background.

You can suppress the images download logging by adding `--quiet-pull` flag. Refer to
[Docker Compose](https://docs.docker.com/reference/cli/docker/compose/) documentation for more commands and flags that
can be used.

> **NOTE**: If you use the compose file as is, it will setup example repository and use queries to build up index for
the reconciliation. We recommend updating the compose file or use it just as example reference in order to setup the
services for your own data.

> **NOTE**: There is an external volume, which is need in case you are using queries for the index data. This volume
needs to be created manually. You can just execute `docker volume create index_data`.

> **NOTE**: You may need to use `sudo` in order to install the environment correctly. It depends on the permissions
given to Docker, when it was installed. The permissions are required in order to create additional files and directories
in the mounted volumes.

Refer to [Configurations](#configurations) section for more customization options.

### Uninstall

To stop and remove the services, use the following command:

```bash
docker compose -f docker-compose.yaml down
```

Use `--volumes` flag to remove the persisted data, effectively deleting the docker volumes.

> **NOTE**: If the installation was done with `sudo`, you may want to use `sudo` for the uninstallation as well.

## Version Upgrades

When switching to newer versions of the services, make sure to review the [MIGRATION-GUIDE.md](./MIGRATION-GUIDE.md) for
entries, related to the versions that you are going to use.

The versions of the components are provided as arguments from [.env](./.env) file and they also have assigned default
values, in case the `.env` file is missing.

If you want to use different versions, you can either:

* update the versions in the `.env` file (recommended)
* update the versions in the compose file directly

> **NOTE**: At the moment the `Reconciliator` service is compatible with `Elasticsearch 7.x.x`. There are plans for
updating it to newer versions and also adding support for `OpenSearch`.

## Configurations

This section provides information about the configuration options for each of the component and resource. Most of the
components are pre-configured with default values.

However, there are some configurations without default values, which are required. Their values depend on the use case
in which the deployment is used, in particular the datasets that are used as sources for the Reconciliation API.

Make sure to read and understand, what each of the configurations listed below do and how it will change the behavior of
the system when changed.

### Components

#### Reconciliator

##### Application Configurations

Below you can find the list of the application configurations, which are currently supported by the `Reconciliator`.
Each value can be overridden by setting a pair of key and value as `JAVA_OPTS` into the `reconciliator.environment`
section in the compose file.

The configurations must be prefixed with `-D` in order to pass them correctly to the application.

Alternatively, you can add the configurations in the `application.yaml` file that is provisioned to the application.

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
  environment:
    JAVA_OPTS: >-
      -Dlogging.level.root=DEBUG
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

#### Index Manager

##### Application Configurations

Below you can find the list of the application configurations, which are currently supported by the `Index Manager`.
Each value can be overridden by setting a pair of key and value as `JAVA_OPTS` into the `index-manager.environment`
section in the compose file.

The configurations must be prefixed with `-D` in order to pass them correctly to the application.

Alternatively, you can add the configurations in the `application.yaml` file that is provisioned to the application.

| Key                         | Default Value                   | Description                                                                                                          |
|-----------------------------|---------------------------------|----------------------------------------------------------------------------------------------------------------------|
| elasticsearch.host          | "http://elastic:9200"           | The address of the `Elasticsearch` instance, which indices will be managed by the application                        |
| elasticsearch.updateCronJob | "0 0 2 * * *"                   | Controls the frequency of the indices updates. The value should be valid Spring Boot Cron Expression                 |
| graphdb.host                | "http://graphdb:7200"           | The address of the `GraphDB` instance, where the connectors will be created                                          |
| graphdb.repo                | "example"                       | The identifier of the GraphDB Repository, where the connectors will be created                                       |
| graphdb.username            | ""                              | Username for connection to the `GraphDB`, if the security is enabled                                                 |
| graphdb.password            | ""                              | Password for connection to the `GraphDB`, if the security is enabled                                                 |
| index.sourceDirectory       | "/opt/index-manager/connectors" | Path to the directory, where the connector query files should be retrieved                                           |
| index.outputDirectory       | "/opt/index-manager/index-data" | Path to the output directory, where the application will store indices status and additional static RDF data related |
| logging.pattern.level       | "%5p %X{X-Request-ID}"          | Spring Boot configuration, controls the format of the logging messages                                               |

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

#### GraphDB

For the list of configurations, values and general details on the component, please refer to the official
[GraphDB Documentation](https://graphdb.ontotext.com/documentation/10.7/index.html).

In particular, you may want to look at:
[Configuration Properties](https://graphdb.ontotext.com/documentation/10.7/directories-and-config-properties.html#configuration-properties).

#### Elasticsearch

For the full list of configurations, values and general details on the component, please refer to the official
[Elasticsearch Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/7.17/settings.html).

## Examples (TBD)

The directory [examples](./examples/) contains different example setups and configurations for the current chart.

Check them out and follow the `README` files in order to spin up the environment.

## Use Cases

We have a separate GitHub repository containing
[Reconciliation Use Cases](https://github.com/Ontotext-AD/reconciliation-use-cases). 

There are several sets of specific data and resources for use cases, where the Reconciliation Service is useful.
Each use case provides the configurations and data in order to setup the `Ontotext Reconciliation` over it.

## Maintainers

| Name     | Email                         | Url                        |
| -------- | ----------------------------- | -------------------------- |
| Ontotext | <reconciliation@ontotext.com> | <https://www.ontotext.com> |

## License

Refer to the [LICENSE](../../LICENSE) files.
