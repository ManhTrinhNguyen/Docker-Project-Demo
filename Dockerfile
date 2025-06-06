# Build Stage 
FROM node:24-alpine As build 

RUN mkdir -p /home/app

WORKDIR /home/app

# Copy only package files to leverage Docker cache
COPY ./app/package*.json /home/app

# Install dependencies 
RUN npm install

# Copy the rest of application 
COPY ./app /home/app

# Run Stage 
FROM node:24-alpine

ENV MONGO_DB_USERNAME=admin \
    MONGO_DB_PWD=password

# set default dir so that next commands executes in /home/app dir
WORKDIR /home/app

# # Copy node_modules and source code from build stage
COPY --from=build /home/app /home/app

# Run the app 
CMD ["node", "server.js"]