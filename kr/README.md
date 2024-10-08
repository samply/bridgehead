# Krebsregister
## Overview

The **Krebsregister** project is designed to pilot the connection between cancer registries across Germany by providing a federated overview of the available data. This allows for efficient querying and aggregation of data from multiple sources, empowering cancer research and healthcare analysis at a federal state level while ensuring privacy, data minimization, and data sovereignty.

This project integrates several key modules to enable secure, scalable, and flexible data querying across federated registries. The core components used in this setup are:

- [Blaze FHIR Server](https://github.com/samply/blaze.git): For managing FHIR-based medical data.
- [Focus](https://github.com/samply/focus.git): A tool for executing federated queries.
- [Beam Proxy](https://github.com/samply/beam.git): To securely connect the registry to the federated network.
- [oBDS2FHIR](https://github.com/samply/obds2fhir.git): For automated ETL (Extract, Transform, Load) of oBDS data into FHIR-compatible formats.

## Installation

To install the **Krebsregister** project bridgehead, use the following command (in the directory ```/srv/docker/bridgehead```):
```bash

./bridgehead install kr
```
This command will interactively guide you through the installation process and set up the required modules, including Blaze, Focus, Beam Client, and oBDS2FHIR, with all the necessary configuration in place.
## Running the Project

Once installed, start the Krebsregister services with the following command:

```bash

systemctl start bridgehead@kr
```
This will activate the preconfigured modules and establish connections to the federated cancer registry network.

For a deatiled overview see main [README.md](../README.md)