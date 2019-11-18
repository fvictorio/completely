FROM node:10

RUN apt-get update && apt-get install bash-completion

WORKDIR /completely

COPY package.json .
RUN npm install
COPY . .

RUN ./node_modules/.bin/lerna bootstrap

WORKDIR /completely/packages/e2e

CMD ["bash", "--init-file", "run-tests.sh", "-i", "-c", "exit"]
