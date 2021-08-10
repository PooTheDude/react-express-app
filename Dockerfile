# --------------> The production image
FROM node:latest
COPY . /app
WORKDIR /app
RUN yarn &&\
    yarn run start &&\
    yarn run build &&\ 
    cd frontend &&\
    yarn &&\
    yarn run start &&\
    yarn run build &&\
