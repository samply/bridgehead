# Exporter and Reporter


## Exporter
The exporter is a REST API that exports the data of the different databases of the bridgehead in a set of tables.
It can accept different output formats as CSV, Excel, JSON or XML. It can also export data into Opal.

## Exporter-DB
It is a database to save queries for its execution in the exporter. 
The exporter manages also the different executions of the same query in through the database.

## Reporter
This component is a plugin of the exporter that allows to create more complex Excel reports described in templates.
It is compatible with different template engines as Groovy, Thymeleaf,...
It is perfect to generate a document as our traditional CCP quality report.
