FROM node:19-buster

RUN mkdir /src

COPY . /src

WORKDIR /src

RUN yarn

EXPOSE 3000

CMD yarn start