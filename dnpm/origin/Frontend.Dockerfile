FROM node:10-alpine

ARG DNPM_BWHC_FRONTEND_ZIP

# Change to latest release
# Required for image build using local copy of zip file
ARG VERSION=2207

# nuxt host and port to be replaced in package.json. (See 2.3 in bwHCPrototypeManual)
# NUXT_HOST should have a value with public available IP address from within container.
# If changing NUXT_PORT, also change exposed port.
ARG NUXT_HOST=0.0.0.0
ARG NUXT_PORT=3000

# Backend access setup. (See 2.4 in bwHCPrototypeManual)
ARG BACKEND_PROTOCOL=http
ARG BACKEND_HOSTNAME=localhost
ARG BACKEND_PORT=8080

ADD ${DNPM_BWHC_FRONTEND_ZIP} /
RUN unzip $(basename ${DNPM_BWHC_FRONTEND_ZIP}) && rm $(basename ${DNPM_BWHC_FRONTEND_ZIP})

WORKDIR /bwhc-frontend

RUN npm install

# Prepare package.json
RUN sed -i -r "s/^(\s*)\"host\"[^,]*(,?)/\1\"host\": \"$NUXT_HOST\"\2/" ./package.json
RUN sed -i -r "s/^(\s*)\"port\"[^,]*(,?)/\1\"port\": \"$NUXT_PORT\"\2/" ./package.json

# Prepare nuxt.config.js
RUN sed -i -r "s/^(\s*)baseUrl[^,]*(,?)/\1baseUrl: process.env.BASE_URL || '$BACKEND_PROTOCOL:\/\/$BACKEND_HOSTNAME'\2/" ./nuxt.config.js
RUN sed -i -r "s/^(\s*)port[^,]*(,?)/\1port: process.env.port || ':$BACKEND_PORT'\2/" ./nuxt.config.js

RUN npm run generate

EXPOSE $NUXT_PORT

CMD npm start
