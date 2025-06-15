- [Docker Project For Local Development](#Docker-Project-For-Local-Development)

- [Docker Compose Project](#Docker-Compose-Project)

- [Build Dockerfile](#Build-Dockerfile)

- [Deploy Docker Application on a Server](#Deploy-Docker-Application-on-a-Server)

  - [Push Docker Image to Private Repo ECR](#Push-Docker-Image-to-Private-Repo-ECR)

  - [Deploy](#Deploy)

- [Docker volume Demo](#Docker-volume-Demo)

  - [Prerequisites](#Prerequisites)

  - [Defined Named Volume in Docker Compose File](#Defined-Named-Volume-in-Docker-Compose-File)

  - [Docker Volume locations](#Docker-Volume-locations)

- [Create Docker Reposiotry on Nexus and push to it](#Create-Docker-Reposiotry-on-Nexus-and-push-to-it)

  - [Create User Role for Docker Repo](#Create-User-Role-for-Docker-Repo)
 
  - [Docker Login to Nexus Docker Repo](#Docker-Login-to-Nexus-Docker-Repo)
 
  - [Push Image to Nexus Repo](#Push-Image-to-Nexus-Repo)
 
  - [Pull Docker Image from Nexus](#Pull-Docker-Image-from-Nexus)

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

## Build Dockerfile 

Dockerize Nodejs application and push to private Docker registry

Technologies used:

- Docker, Node.js
  
Project Description:

- Write Dockerfile to build a Docker image for a Nodejs application

- Create private Docker registry on AWS (Amazon ECR)

- Push Docker image to this private repository

To Deploy my application should be packaged into its own docker container . This mean we will build a Docker Image by using Dockerfile 

#### What is Dockerfile 

In order to build a Docker image from an application we basically have to copy the contents of that application into the Dockefile could be an artifact that we built in this case we just have 3 files so we copy directly in the image and we will configure it . In order to do that we will use a Blueprint of create Docker image called Dockerfile

- Copy Artifact (war, jar, bundle.js)

**Syntax of Dockefile**:

`FROM image`: Whatever Image we building we want to base it on another image . In this case we have Javascript app with Nodejs backend so that it can run our node application instead of basing it on a Linux Alpine or some other lower level and we have to install node on it (https://hub.docker.com/_/node)

- This mean base on our `Node` image we will have node install inside of our image

`ENV` We can configure ENV inside of Dockerfile (But should configure ENV outside Dockerfile. More Flexible) 

`RUN` I can execute any kind of Linux commands inside of the Container not on the host  

`COPY <src> to <dest>` : This execute on the host . 

- src: Is from the host

- dest: Inside the container

`WORKDIR`: Set a default directory inside the Docker container . (So I don't have to specify absolute path inside docker container)  

`CMD` : Execute an entry point Linux Command 

- Different between `RUN` and `CMD` . I can have multiple `RUN` command but I can only have 1 entry point which is `CMD`

**Create Dockerfile**

`FROM node:24-alpine` : Since we saw Dockerfile is a blueprint for any Docker image that should acutally mean that every Docker image that there is on Dockerhub should be built on its own Dockerfile 

- Every Image is based off another base image

`RUN npm install`: The reason we run npm install is that instead of taking the `node_modules` that we have on our host inside the project and copy it into the image we want to execute npm install and generate that `node_modules` with  all the dependencies inside while creating the Docker image to make sure we have the most up to date version 

Once  I created my Dockerfile I can start to build it 

**Image Layer**

Our own image that we are build `nodejs-app:1.0` will be based on Node Image with specific version `node:24-alpine` . 

And the `node:24-alpine` image is base on `alpine:3.17` image 

Alpine is a lightweight Linux Image that we install Node on top of and then we install our own application on top of that Node image 

**Build Dockerfile**

To build Docker file : `docker build -t nodejs-app:1.0 .`

To docker build command we have to provide 2 parameters 

- 1 is we want to give our image a name and a tag

- 2 location of dockerfile . In this case we are in the same folder so I could do `.`

To see my images `docker images`

To delete Image `docker rmi <image-id>`

IF image is being used I can not delete that. To see if it being used  `docker ps -a`

Then to remove that container `docker rm <container-id>`

To check inside the container `docker exec -it <container-id> /bin/bash` 

Some container don't have `bash` I can do `docker exec -it <container-id> /bin/sh` 

**Never run as Root User**

Now when we create this Image and run it as a Container Which OS user will be use to start the Application inside ?

By default Dockerfile does not specify a user it uses a Root User . But in reality never should run Application as Root User

The Solution is to create dedicate User with a dedicated Group in Docker Image to run Application 

With `node:24-alpine` image `groupadd` and `useradd` do not exist in `Alpine` by default.

- I need to install `shadow` package to get groupadd and useradd `RUN apk add --no-cache shadow`
  
To create user and group in Image : `RUN groupadd -r tim && useradd -g tim tim`.

Then I set ownership and permission to that user : `RUN chown -R tim:tim /app`

Then I switch to that User : `USER tim`

Then I run the App : `CMD ["node", "server.js"]`

To check it work can go inside the container `docker exec -it <container-id> /bin/sh` and use command `whoami` It will appear `tim`

## Deploy Docker Application on a Server

Demo Project:

- Deploy Docker application on a server with Docker Compose

Technologies used:

- Docker, Amazon ECR, Node.js, MongoDB, MongoExpress

Project Description:

- Copy Docker-compose file to remote server

- Login to private Docker registry on remote server to fetch our app image

- Start our application container with MongoDB and MongoExpress services using docker compose

#### Push Docker Image to Private Repo ECR 

I just create my Nodejs Docker Image from my Local machine 

Now I want to push that Image into ECR 

Before I can do that I need to have `aws cli` in my local machine : 

- Installing AWS CLI on MacOS: (https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-macOS.html)

Then I will configure Credentials for the AWS CLI (https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

Now I will go to my AWS Console ECR to create my Private Repo 

Now I have my Repository name `nodejs`

One thing specific to ECR is that here I create a Docker Repo per image . So I don't have the repository where I can actually push multiple images of differents applications but rather for each Image I have its own repository 

What I store in the repository are the different tags or different versions of the same image 

There is 2 things I need to do in order to push Image to ECR :

- Login into ECR (I have to authenticate myself) . If Docker Image built and push from Jenkins Server I have to give Jenkins Credentials to login into Repository `aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin 660753258283.dkr.ecr.us-west-1.amazonaws.com` .

- I need to tag my Image

Image Name concepts in Docker Repo 

- `registryDomain/imageName:tag` : THis is a naming in Docker Registries

- `registryDomain` is the registry Domain (host, port etc...)

-  `imageName:tag` This is actual image name and the tag

-  But with Dockerhub we able to pull an image without having to specify a registry domain . This command `docker pull mongo:4.2` is a shorthand of this command `docker pull docker.io/library/mongo:4.2`

-  In the Private Repo Registry we can't skip this part bcs there is no default configuration for it

So In ECR I will do this : `660753258283.dkr.ecr.us-west-1.amazonaws.com/nodejs:1.0`

We have to tag our image like that to tell Docker that I want to push my Image to this Registry Domain which is ECR 

Tag meaning rename our image to include the repository domain : `docker tag myapp:1.0 660753258283.dkr.ecr.us-west-1.amazonaws.com/nodejs:1.0`

Now I can push the image like this : `docker push 660753258283.dkr.ecr.us-west-1.amazonaws.com/nodejs:1.0`

#### Deploy

In the Project above I have created my own Docker Image 

In order to start an application on development server, I would need all the containers that make up that application environment 

This is what my docker-compose look like 

```
version: '3'
services:
  mongodb: # container name 
    image: mongo # Image of the container 
    ports:
     - 27017:27017
    environment:
     - MONGO_INITDB_ROOT_USERNAME=admin
     - MONGO_INITDB_ROOT_PASSWORD=password
  mongo-express:
    image: mongo-express
    restart: always
    ports:
     - 8081:8081
    environment:
     - ME_CONFIG_MONGODB_ADMINUSERNAME=admin
     - ME_CONFIG_MONGODB_ADMINPASSWORD=password
     - ME_CONFIG_MONGODB_SERVER=mongodb
     - ME_CONFIG_BASICAUTH_USERNAME=user
     - ME_CONFIG_BASICAUTH_PASSWORD=pass
    depends_on:
     - "mongodb"
  nodejs-app:
    image: 660753258283.dkr.ecr.us-west-1.amazonaws.com/nodejs:1.0 
    depends_on:
      - "mongodb"
    ports:
     - 3000:3000 
    environment:
      - MONGO_DB_USERNAME=admin
      - MONGO_DB_PWD=password
```

I have my own Image that I created before (Nodejs) that run on port 3000 

- I am pulling my nodejs Image from ECR so my image name should look like this `image: 660753258283.dkr.ecr.us-west-1.amazonaws.com/nodejs:1.0`

- In order to pull this Image, the environment where I execute this Docker Compose file have to be logged into a Docker Repository

I have configured mongdb and mongo express . I configured on the project above  

Docker Network and how Docker Compose take care of it is that when I connect 1 application in a Docker container with another in another Docker container, I don't have to use `localhost` . So the host name and the port number are implicitly configured in the `container name`

Now I `ssh` to the remote server and copy that docker compose file and run in there 

- I need to log in to ECR `aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin 660753258283.dkr.ecr.us-west-1.amazonaws.com` . Also my AWS Credentials have to available in that Remote Server

- I need to install docker and docker compose on that server .

- After that I can start docker compose : `docker-compose -t <docker-compose.yaml> up`

## Docker volume Demo

Demo Project:

- Persist data with Docker Volumes
  
Technologies used:
  
- Docker, Node.js, MongoDB

Project Description:

- Persist data of a MongoDB container by attaching a Docker volume to it

#### Prerequisites

I will first deploy the applications (Nodejs, MongoDB, MongExpress) by using docker-compose that I created above . 
 
Then I go to MongoExpress UI `localhost:8081` I create a `databaseName: user-account` and then I will create a `users` collections 

In order connect to the DB. I configure this in my `server.js`

```
let databaseName = "user-account"; # This will match the DB name I just created 
let collectionName = "users"; # This will match the collectionName I just created
```

Now If were to recreate the MongoDB containerm I would lose all the data 

#### Defined Named Volume in Docker Compose File 

I want to persist all the data even if Docker Container Recreate

First I will define what volmes I will be using in any of my containers . I will configure that in `services` level

```
volumes: # List of all the volumes I am using in any of my containers
 mongo-data:
  driver: local
```

- `mongo-data`: This is a name of the volume reference

- `driver: local` : THe acutal storage path, that we will see later once it's created is acutally created by Docker itself . And this is a additional information for Docker to create that physical storage on a local file system . For example `/var/lib/docker/volumes/mongo-data/_data`


Now I have a named Reference Volume define I can use it in the container . In the `mongdb` container at the `image` level I will define `volume`

```
volumes:
 - mongo-data:/data/db
```

- `mongo-data`: Is the named volume that I defined (This is a volume I have on the host)

- `/data/db`: This is the path inside the MongoDB container. It has to be the path where MongoDB explicitly persists its data

Now all the data inside the container in this path `/data/db` will be replicated on the container startup on my host, on this persitence volume `mongo-data` I defined and vice versa .

This is my complete docker-compose file: 

```
services:
  mongodb: # container name 
    image: mongo # Image of the container 
    ports:
     - 27017:27017
    environment:
     - MONGO_INITDB_ROOT_USERNAME=admin
     - MONGO_INITDB_ROOT_PASSWORD=password
    volumes:
     - mongo-data:/data/db
  mongo-express:
    image: mongo-express
    restart: always
    ports:
     - 8081:8081
    environment:
     - ME_CONFIG_MONGODB_ADMINUSERNAME=admin
     - ME_CONFIG_MONGODB_ADMINPASSWORD=password
     - ME_CONFIG_MONGODB_SERVER=mongodb
     - ME_CONFIG_BASICAUTH_USERNAME=user
     - ME_CONFIG_BASICAUTH_PASSWORD=pass
    depends_on:
     - "mongodb"
  nodejs-app:
    image: nodejs 
    depends_on:
      - "mongodb"
    ports:
     - 3000:3000
    environment:
      - MONGO_DB_USERNAME=admin
      - MONGO_DB_PWD=password
volumes:
  mongo-data:
    driver: local
```

Now If I were to recreate all these containers, these data should be persisted 

#### Docker Volume locations

On Linux : `/var/lib/docker/volumes`

On Mac : `/var/lib/docker/volumes`

On Window: `C:\ProgramData\docker\volumes`

Inside of this volumes directory I have a list of all the volumes that one or many containers are using and each volumes has its own hash, which has to be unique

With Docker for Macs we need to execute this command `docker run -it --privileged --pid=host debian nsenter -t 1 -m -u -n -i sh` which will allow us to enter the shell of the Docker VM that container is using. So we can view the Docker data about the containers and its volumes

- This is different from running `docker exec -it <container_id>` .

- This will start up a new container and allow us to connect to it from here

- After execute this command I will get into a terminal of Docker container . Then I can see a list of volumes by using this command `ls /var/lib/docker/volumes`

Now If I go inside of the Mongo DB container `docker exec -t <container-id> sh` and execute this command `ls /var/lib/docker/volumes` I would see the same list of volume

## Create Docker Reposiotry on Nexus and push to it 

Demo Project:

- Create Docker repository on Nexus and push to it
  
Technologies used:

- Docker, Nexus, DigitalOcean, Linux

Project Description:

- Create Docker hosted repository on Nexus
  
- Create Docker repository role on Nexus
  
- Configure Nexus, DigitalOcean Droplet and Docker to be able to push to Docker repository

- Build and Push Docker image to Docker repository on Nexus

----

In Nexus Go to Repositories -> Create Repository -> Choose Docker(hosted)

- Select Blob store

- And Create that

Now If I go inside I should have a Reposiotry URL of the repository which can use to push Docker Image 

<img width="600" alt="Screenshot 2025-06-15 at 13 39 44" src="https://github.com/user-attachments/assets/9b757fc8-91dc-470d-a311-d5e162924469" />

#### Create User Role for Docker Repo

First I need login to Nexus using a Nexus user  which has access to Docker hosted repository 

I need to create a new Roles that has a privikege or access to Docker Hosted repository 

`Privileges Selection` : Choose `nx-repository-view-docker-docker-hosted-*`

<img width="600" alt="Screenshot 2025-06-15 at 13 43 50" src="https://github.com/user-attachments/assets/80a9f2cf-86c8-4c9c-b7ec-71118bf35b54" />

And the I can assgin a Roles to my User . Go to Users choose my-user then assign the role to that user 

#### Docker Login to Nexus Docker Repo 

First I need to go to Docker-hosted Repo and edit `HTTP` field 

- Reason is Docker Client cannot connect to a path which represent a Docker Repo, So we can not use this as an endpoint for Docker Login . This endpoint is `ipaddress:port` however this port itself is where Nexus is running .

- So we need a Port for Docker repo speicifically, so its own individual port where Docker Repository will be accessible at

- `Reposiotry Connectors` is only available in Docker type

- I can set a Port `HTTP:8083`

Now this Docker Repo is accessible at `ipaddress:8083`

Now I go to a Droplet Server Terminal where Nexus is running and do `netstat -lntp` I can see a port 8083 opened 

<img width="600" alt="Screenshot 2025-06-15 at 13 51 48" src="https://github.com/user-attachments/assets/81a722f6-72d4-4f7e-8a8d-3905a29d9fa7" />

Now I need to open this Port on a Droplet Firewall 
 
<img width="803" alt="Screenshot 2025-06-15 at 13 53 11" src="https://github.com/user-attachments/assets/8930ba47-579e-468d-8612-0a52c89212d8" />

Final thing I need to configure is `Realms`

- When we do a login we have a token of authentication from Nexus Docker reposiotry for a client and that token will be stored the on my local machine in a file called `cat ~/.docker/config.json`. And this json file will include all the authentication that I have made to all the different Docker repository . If you haven't logged in to a Docker Repository from my laptop you won't have this file

- So we need to configure in Neuxus issuing of that Token `Docker Bearer Token Realm` . we will activated

One more configure I have to do in Docker itself . Docker by default only allow client requests whenever we execute a command like Docker login , docker pull, docker push, all these commands to go to and talk to an `HTTPS` endpoint, a secure endpoint

- Bcs we have `HTTP` not secure, we need to configure docker client to allow our Docker hosted reposiotry as an insecure registry

- In linux System I can edit a file call `/etc/docker/daemon.json`

```
"insecure-registries": ["myregistrydomain.com:8083"]
```

- If I use Mac or Window I don't have that file locally bcs Docker Desktop acutally starts as a virtual machine on my Mac or Windows.

 - Go to Docker Desktop UI -> Settings -> Docker Engine and then add that code

<img width="600" alt="Screenshot 2025-06-15 at 14 03 44" src="https://github.com/user-attachments/assets/c0646f9d-c2dc-40e9-a38c-2351215c44f1" />

 Now I can do `docker login [nexus ip address]:8083`

 - Put my username and password in there

Now the `~/.docker/config.json` got updated . Now this file have a token that Docker Repository issued back to our Client so that we don't have to Login in every time we execute command to a Repo 

#### Push Image to Nexus Repo 

First we will build an image `docker build -t nodejs-app:1.0 .`

I need to Re tag the image to include the address or the name of the Repository : `docker tag nodejs-app:1.0 [nexus-ip-address:8083]/nodejs-app:1.0` 

- This implicitly tell Docker where to push this image to 

To check images : `docker images`

To push Image : `docker push [nexus-ip-address:8083]/nodejs-app:1.0`

Now I can see my Image in the Nexus Docker-hosted Repository 

<img width="600" alt="Screenshot 2025-06-15 at 14 12 12" src="https://github.com/user-attachments/assets/11a61254-33ef-4761-9e79-0ab786265453" />

#### Pull Docker Image from Nexus

I can use Nexus API to pull Docker Image `curl -u tim:password -X GET '164.92.135.47:8081/service/rest/v1/components?repository=docker-hosted'`

Once I execute it I should have a `items`

<img width="600" alt="Screenshot 2025-06-15 at 14 17 13" src="https://github.com/user-attachments/assets/45cea9fe-fc87-47e9-b377-fbbbe4a51a60" />

This way I can retrive the Docker Images from endpoint with some information 