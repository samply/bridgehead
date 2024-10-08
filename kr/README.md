# Krebsregister
## Overview

The **Krebsregister** project is designed to pilot the connection between cancer registries across Germany by providing a federated overview of the available data. This allows for efficient querying and aggregation of data from multiple sources, empowering cancer research and healthcare analysis at a federal state level while ensuring privacy, data minimization, and data sovereignty.

This project integrates several key modules to enable secure, scalable, and flexible data querying across federated registries. The core components used in this setup are:

- Blaze FHIR Server: For managing FHIR-based medical data.
- Focus: A tool for executing federated queries.
- Beam Proxy: To securely connect the registry to the federated network.
- oBDS2FHIR: For automated ETL (Extract, Transform, Load) of oBDS data into FHIR-compatible formats.

## Modules in Use
- Blaze FHIR Server
- Focus
- Beam Client
- oBDS2FHIR-REST

## Installation

To install the **Krebsregister** project, use the following command (in the directory ```/srv/docker/bridgehead```):
```bash

./bridgehead install kr
```
This command will set up the required modules, including Blaze, Focus, Beam Client, and oBDS2FHIR, with all the necessary configurations in place.
Running the Project

Once installed, start the Krebsregister services with the following command:

```bash

systemctl start bridgehead@kr
```
This will activate the preconfigured modules and establish connections to the federated cancer registry network.

For a deatiled overview see main [README.md](../README.md)