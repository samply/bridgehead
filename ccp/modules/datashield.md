# DataSHIELD
This module constitutes the infrastructure to run DataSHIELD within the bridgehead. 
For more information about DataSHIELD, please visit https://www.datashield.org/

## R-Studio
To connect to the different bridgeheads of the CCP through DataSHIELD, you can use your own R-Studio environment.
However, this R-Studio has already installed the DataSHIELD libraries and is integrated within the bridgehead.
This can save you some time for extra configuration of your R-Studio environment.

## Opal
This is the core of DataSHIELD. It is made up of Opal, a Postgres database and an R-server.
For more information about Opal, please visit https://opaldoc.obiba.org

### Opal
Opal is OBiBa’s core database application for biobanks. 

### Opal-DB
Opal requires a database to import the data for DataSHIELD. We use a Postgres instance as database. 
The data is imported within the bridgehead through the exporter.

### Opal-R-Server
R-Server to execute R scripts in DataSHIELD.

## Beam
### Beam-Connect
Beam-Connect is used to route http(s) traffic through beam to enable R-Studio to access data from other bridgeheads that have datashield enabled.
### Beam-Proxy
The usual beam proxy used for communication.
