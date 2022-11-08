FROM openjdk:11-jre AS builder

ARG DNPM_BWHC_BACKEND_ZIP

# Change to latest release
ARG VERSION=broker

ARG BWHC_BASE_DIR=/bwhc-backend

ENV BWHC_BASE_DIR=$BWHC_BASE_DIR
ENV BWHC_USER_DB_DIR=$BWHC_BASE_DIR/data/user-db
ENV BWHC_DATA_ENTRY_DIR=$BWHC_BASE_DIR/data/data-entry
ENV BWHC_QUERY_DATA_DIR=$BWHC_BASE_DIR/data/query-data

ADD ${DNPM_BWHC_BACKEND_ZIP} /
RUN unzip $(basename ${DNPM_BWHC_BACKEND_ZIP}) && rm $(basename ${DNPM_BWHC_BACKEND_ZIP})

WORKDIR $BWHC_BASE_DIR

# Prepare config file to use environment variables from docker
RUN sed -i -r "s/APPLICATION_SECRET(.*)/#APPLICATION_SECRET\1/" ./config
RUN sed -i -r "s/ZPM_SITE(.*)/#ZPM_SITE\1/" ./config

# Prepare config file to use fix environment variables for this image
RUN sed -i -r "s~BWHC_DATA_ENTRY_DIR.*~BWHC_DATA_ENTRY_DIR=$BWHC_DATA_ENTRY_DIR~" ./config
RUN sed -i -r "s~BWHC_QUERY_DATA_DIR.*~BWHC_QUERY_DATA_DIR=$BWHC_QUERY_DATA_DIR~" ./config
RUN sed -i -r "s~BWHC_USER_DB_DIR.*~BWHC_USER_DB_DIR=$BWHC_USER_DB_DIR~" ./config

RUN ./install.sh $BWHC_BASE_DIR

RUN mv bwhc-rest-api-gateway-*/  bwhc-rest-api-gateway/

FROM openjdk:11-jre

ARG BWHC_BASE_DIR=/bwhc-backend

ENV BWHC_BASE_DIR=$BWHC_BASE_DIR
ENV BWHC_USER_DB_DIR=$BWHC_BASE_DIR/data/user-db
ENV BWHC_DATA_ENTRY_DIR=$BWHC_BASE_DIR/data/data-entry
ENV BWHC_QUERY_DATA_DIR=$BWHC_BASE_DIR/data/query-data
ENV BWHC_CONNECTOR_CONFIG=$BWHC_BASE_DIR/bwhcConnectorConfig.xml

COPY --from=builder $BWHC_BASE_DIR/config $BWHC_BASE_DIR/
COPY --from=builder $BWHC_BASE_DIR/bwhcConnectorConfig.xml $BWHC_BASE_DIR/
COPY --from=builder $BWHC_BASE_DIR/logback.xml $BWHC_BASE_DIR/
COPY --from=builder $BWHC_BASE_DIR/production.conf $BWHC_BASE_DIR/
COPY --from=builder $BWHC_BASE_DIR/bwhc-rest-api-gateway/ $BWHC_BASE_DIR/bwhc-rest-api-gateway/

VOLUME $BWHC_BASE_DIR/data
VOLUME $BWHC_BASE_DIR/hgnc_data

EXPOSE ${BWHC_BACKEND_PORT}

WORKDIR $BWHC_BASE_DIR

CMD $BWHC_BASE_DIR/bwhc-rest-api-gateway/bin/bwhc-rest-api-gateway \
    -Dplay.http.secret.key=$APPLICATION_SECRET \
    -Dconfig.file=$BWHC_BASE_DIR/production.conf \
    -Dlogger.file=$BWHC_BASE_DIR/logback.xml \
    -Dpidfile.path=/dev/null \
    -Dbwhc.zpm.site=$ZPM_SITE \
    -Dbwhc.data.entry.dir=$BWHC_DATA_ENTRY_DIR \
    -Dbwhc.query.data.dir=$BWHC_QUERY_DATA_DIR \
    -Dbwhc.user.data.dir=$BWHC_USER_DB_DIR \
    -Dbwhc.hgnc.dir=$BWHC_HGNC_DIR \
    -Dbwhc.connector.configFile=$BWHC_CONNECTOR_CONFIG
