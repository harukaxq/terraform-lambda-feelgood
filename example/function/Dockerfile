FROM --platform=linux/amd64 public.ecr.aws/lambda/nodejs:18
ARG SENTRY_AUTH_TOKEN
ARG SENTRY_URL
ARG SENTRY_PROJECT_NAME
ARG SENTRY_RELEASE
ARG SENTRY_ORG_NAME
ARG MODE

WORKDIR /code/
RUN npm install -g yarn
COPY ./package.json ./yarn.lock ./tsconfig.json ./esbuild.config.mjs ./.eslintrc.js /code/
RUN yarn install --frozen-lockfile
COPY ./src /code/src
RUN mkdir -p /app/
WORKDIR /code/
RUN SENTRY_URL=${SENTRY_URL} SENTRY_ORG_NAME=${SENTRY_ORG_NAME} SENTRY_AUTH_TOKEN=${SENTRY_AUTH_TOKEN} SENTRY_PROJECT_NAME=${SENTRY_PROJECT_NAME} SENTRY_RELEASE=${SENTRY_RELEASE} yarn build
RUN cp -r .build/* ${LAMBDA_TASK_ROOT}
CMD [ "index.handler" ]
