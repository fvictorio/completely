FROM node:10

RUN apt-get update && apt-get install -y bash-completion zsh

WORKDIR /completely

COPY package.json .
RUN npm install
COPY . .

RUN ./node_modules/.bin/lerna bootstrap
RUN ./node_modules/.bin/lerna link

RUN cd packages/spec && yarn build
RUN cd packages/bash-generator && yarn build
RUN cd packages/cli && yarn prepack

RUN ./node_modules/.bin/lerna add @completely/cli --scope=@completely/e2e

WORKDIR /completely/packages/e2e

CMD ["./run-all-tests.sh"]
