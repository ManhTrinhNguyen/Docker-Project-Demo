- [Docker Project For Local Development](#Docker-Project-For-Local-Development)

- [Docker Compose Project](#Docker-Compose-Project)

## Docker Project For Local Development 

<img width="600" alt="Screenshot 2025-06-06 at 12 37 25" src="https://github.com/user-attachments/assets/50d39c6a-3ee5-4582-9940-69d015b582b2" />

#### Project Overview 

Use Docker for local development

Technologies used:

- Docker, Node.js, MongoDB, MongoExpress

Project Description:

- Run Nodejs application in Localhost and connect to
  
- MongoDB database container locally. Also run MongoExpress container as a UI of the MongoDB
database.

#### Docker in Software Development 

First will be a simple UI backend application using Javascript, HTML structure and Nodejs in the backend 

In order to intergrate into the DB, we will use a Docker container MongoDB . Also to make working with MongoDB much easier so we will deploy a Docker container MongoExpress which is a MongoDB UI where we can see the database structure 

#### MongoDB Image and Mongo Express Images 

Go to DockerHub and get the MongoDB Image  (https://hub.docker.com/_/mongo)

Mongo Express Image (https://hub.docker.com/_/mongo-express)

To pull MongDB : `docker pull mongo` -> This will pull a latest version

To pull MongExpress: `docker pull mongo-express`  -> This will pull a latest version

#### Docker Network 

In order to run both MongoDB and Mongo express containers and available for my Nodejs application and also connect them together we need `Docker Network`

Docker create the isolated Docker network where containers are running in. 

- When I deploy 2 containers in the same Docker Network, they can talk to each other using just `container name` with `localhost:port` .

- And Application that run outside of Docker Network which is Nodejs will connect to them from outside or from the host using `localhost:port`

- Later when package our application into its own Docker Image . We will have Docker Network with MongoDB container, MongExpress container and Nodejs Application 

To see Docker network : `docker network ls`

To create my own network : `docker network mongo-network`

To make the docker containers run inside the network we have to make `-n` options 

#### Run MongDB 

To run MongDB : 

```
docker run -d \
-p 27017:27017 \
--name mongodb \
--net mongo-network \
-e MONGO_INITDB_ROOT_USERNAME=admin
-e MONGO_INITDB_ROOT_PASSWORD=password
mongo
```

`-e MONGO_INITDB_ROOT_USERNAME=admin` and `-e MONGO_INITDB_ROOT_PASSWORD=password` is a root mongodb username and password . We need that for Mongexpress to connect to Mongdb

`-name mongodb` This is a name of the container

`-n mongo-network` This is a network name that I created above 

`mongo` is a image name 

#### Run MongExpress 

To run MongoExpress :

```
docker run -d \
-p 8081:8081 \
--net mongo-network \
--name mongoexpress \
-e ME_CONFIG_MONGODB_ADMINUSERNAME=admin \
-e ME_CONFIG_MONGODB_ADMINPASSWORD=password \
-e ME_CONFIG_MONGODB_SERVER=mongodb \
-e ME_CONFIG_BASICAUTH_USERNAME=user \
-e ME_CONFIG_BASICAUTH_PASSWORD=pass \
-e ME_CONFIG_MONGODB_SERVER=mongodb \
-e ME_CONFIG_MONGODB_URL=mongodb://mongodb:27017 \
mongo-express
```

`--net mongo-network`: The same network where mongdb is running 

`--name mongexpress` : This is a name of the container

`-e ME_CONFIG_MONGODB_ADMINUSERNAME=admin` and `-e ME_CONFIG_MONGODB_ADMINPASSWORD=password` . This is a MongDB username and password that I configured above 

`-e ME_CONFIG_MONGODB_SERVER=mongodb` : This is a container name the express will use to connect to the Docker, bcs they are running in the same network. Only bcs of that this configuration will work  

`-e ME_CONFIG_MONGODB_PORT=27017` : The Port by default is the correct one so i don't need to apply that 

`-e ME_CONFIG_BASICAUTH_USERNAME=user` and `-e ME_CONFIG_BASICAUTH_PASSWORD=pass` I can login using these credentials in mongoexpress 

`-e ME_CONFIG_MONGODB_SERVER=mongodb` I need to connect to mongdb server using MongoDB container name

`-e ME_CONFIG_MONGODB_URL=mongodb://mongodb:27017` : If I don't set this I can get error from Mongo Express logs Say server cannot located 

MongExpress Docs in Dockerhub not up to date . In order to see up to date docs I can go to (https://github.com/mongo-express/mongo-express)

#### Connect Node Server with MongoDB Container

Now we have MongDB and MongExpress container running . We will have to connect Nodejs with DB

To do that we have to give a protocol of the DB and the URI, and the URI for a MongoDB `localhost:27017`

We will use `MongoClient` which node module , and using that `MongoClient` to connect to the MongoDB 

This is a protocol `let mongoUrlLocal = "mongodb://admin:password@localhost:27017"` (Never put password and username in the code . This is just for reference)


## Docker Compose Project

Docker Compose - Run multiple Docker containers

Technologies used:

- Docker, MongoDB, MongoExpress

Project Description:

- Write Docker Compose file to run MongoDB and MongoExpress containers

With docker-compse file we can take the whole command and map it into a file so that we have a structure commands .

- For example: If we have 10 docker containers that we want to run for our applications and they all need to talk to each other and interact with each other. I can basically write all the run commands for each container in a structured way in Docker Compose 

```
version: 3 # Version of Docker compose
services: # This is where a Container list go 
  mongodb:
  mongo-express
  nodejs-app
```

This is a structure of docker-compose 

<img width="600" alt="Screenshot 2025-06-07 at 12 04 32" src="https://github.com/user-attachments/assets/76373f08-795a-431c-9a19-fd9a2cddb225" />

Docker-compose is a strucutred way to container very normal common docker command . It easier for us to edit the file if we want to change some variable or add some new options 

We don't have to create network in Docker-compose whe  have the same concept that we have containers will talk to each other using just the container name . What Docker compose will do is take care of creating a common network for these containers so we don't have to create the network and specify in which network these containers will run 

`restart: always` : Is to make sure Mongo Express connect to MongoDB container when we start the project bcs when we start  both container at once wieth docker-compose, it could be that Mongo-Express container start first or before MongoDB is up and running and obiously won't be able to connect to it bcs there is no database container to connect to so it Mongo Express container will fail . With this configuration we are telling Docker compose to restart the Mongo Express container if it fail to conenct to the database  

There are some other ways to define the order of containers to start in Docker Compose and define that one container starts before the other with configuration like `depends_on` or `heathcheck` 

<img width="600" alt="Screenshot 2025-06-07 at 12 14 59" src="https://github.com/user-attachments/assets/73bd9ce2-4d83-45e7-9b4a-d59edebb9ec1" />

To start docker compose `docker-compose -f <docker-compose file> up`

- After I start docker compose It will automatically create a network for me

- To check network `docker network ls`

To stop docker compose `docker-compose -f <docker-compose file> down`



