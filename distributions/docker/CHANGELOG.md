# CHANGELOG

### {% CHANGE_DATE %}

* Added initial version of the docker compose file, which provides environment and setups `Ontotext Reconciliation`
  service.

  The compose comes with additional resources and configurations, serving as example on how to start and use custom
  instance.

  The [docker-compose.yaml](./docker-compose.yaml) contains the minimum services required for setting up `GraphDB`,
  `Elasticsearch`, `Reconciliation Index Manager` and `Ontotext Reconciliator`. This setup is considered as **default**,
  where the data is added to `GraphDB`, which automatically syncs it with `Elasticsearch`, used as data provider for the
  `Ontotext Reconciliator`.

  The [alternatives](./alternatives/) directory contains examples for different setups. For example, there is an compose
  setting up `Elasticsearch` cluster, there is a compose setting up environment with monitoring, etc.
  Depending on specific use cases, these examples will be extended further.

  Check the [README](./README.md) for detailed information about the setup, resources and configurations included in the
  different compose files.

####################
