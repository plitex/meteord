[![CircleCI](https://circleci.com/gh/plitex/meteord/tree/master.svg?style=svg)](https://circleci.com/gh/plitex/meteord/tree/master)

# Fork information

After some time using the awesome [meteorhacks/meteord](https://github.com/meteorhacks/meteord) and the [abernix/meteord](https://github.com/abernix/meteord) after Meteor 1.4, I was looking to have a base image not bound to a node version. My idea was to be able to detect the app meteor release and install the exact Meteor version to build and the corresponding Node version to run the bundle.

What does this fork offer:

  - Compatible with Meteor 1.2+
  - Meteor & Node version detection
  - Setup NPM to install packages from a private registry
  - PhantomJS is only available in plitex/meteord:testbuild

## MeteorD - Docker Runtime for Meteor Apps

There are two main ways you can use Docker with Meteor apps. They are:

1. Build a Docker image for your app
2. Running a Meteor bundle with Docker

**MeteorD supports these two ways. Let's see how to use MeteorD**

### 1. Build a Docker image for your app

With this method, your app will be converted into a Docker image. Then you can simply run that image.  

For that, you can use `plitex/meteord:onbuild` as your base image. Magically, that's only thing you have to do. Here's how to do it:

Add following `Dockerfile` into the root of your app:

~~~shell
FROM plitex/meteord:onbuild
~~~

Then you can build the docker image with:

~~~shell
docker build -t yourname/app .
~~~

Then you can run your meteor image with

~~~shell
docker run -d \
    -e ROOT_URL=http://yourapp.com \
    -e MONGO_URL=mongodb://url \
    -e MONGO_OPLOG_URL=mongodb://oplog_url \
    -p 8080:80 \
    yourname/app
~~~
Then you can access your app from the port 8080 of the host system.

#### Stop downloading Meteor each and every time (mostly in development)

So, with the above method, MeteorD will download and install Meteor each and every time. That's bad especially in development. So, we've a solution for that. Simply use `plitex/meteord:devbuild` as your base image.

### 2. Running a Meteor bundle with Docker

For this you can directly use the MeteorD to run your meteor bundle. MeteorD can accept your bundle either from a local mount or from the web. Let's see:

#### 2.1 From a Local Mount

~~~shell
docker run -d \
    -e ROOT_URL=http://yourapp.com \
    -e MONGO_URL=mongodb://url \
    -e MONGO_OPLOG_URL=mongodb://oplog_url \
    -v /mybundle_dir:/bundle \
    -p 8080:80 \
    plitex/meteord:base
~~~

With this method, MeteorD looks for the tarball version of the meteor bundle. So, you should build the meteor bundle for `os.linux.x86_64` and put it inside the `/bundle` volume. This is how you can build a meteor bundle.

~~~shell
meteor build --architecture=os.linux.x86_64 ./
~~~

#### 2.1 From the Web

You can also simply give URL of the tarball with `BUNDLE_URL` environment variable. Then MeteorD will fetch the bundle and run it. This is how to do it:

~~~shell
docker run -d \
    -e ROOT_URL=http://yourapp.com \
    -e MONGO_URL=mongodb://url \
    -e MONGO_OPLOG_URL=mongodb://oplog_url \
    -e BUNDLE_URL=http://mybundle_url_at_s3.tar.gz \
    -p 8080:80 \
    plitex/meteord:base
~~~

#### 2.2 With Docker Compose

docker-compose.yml
~~~shell
dashboard:
  image: yourrepo/yourapp
  ports:
   - "80:80"
  links:
   - mongo
  environment:
   - MONGO_URL=mongodb://mongo/yourapp
   - ROOT_URL=http://yourapp.com
   - MAIL_URL=smtp://some.mailserver.com:25

mongo:
  image: mongo:latest
~~~

When using Docker Compose to start a Meteor container with a Mongo container as well, we need to wait for the database to start up before we try to start the Meteor app, else the container will fail to start.

This sample docker-compose.yml file starts up a container that has used plites/meteord as its base and a mongo container. It also passes along several variables to Meteor needed to start up, specifies the port number the container will listen on, and waits 30 seconds for the mongodb container to start up before starting up the Meteor container.

#### Rebuilding Binary Modules

Sometimes, you need to rebuild binary npm modules. If so, expose `REBUILD_NPM_MODULES` environment variable. It will take couple of seconds to complete the rebuilding process.

~~~shell
docker run -d \
    -e ROOT_URL=http://yourapp.com \
    -e MONGO_URL=mongodb://url \
    -e MONGO_OPLOG_URL=mongodb://oplog_url \
    -e BUNDLE_URL=http://mybundle_url_at_s3.tar.gz \
    -e REBUILD_NPM_MODULES=1 \
    -p 8080:80 \
    plitex/meteord:binbuild
~~~

## Setup NPM to access a private registry

You can pass information about a private registry (only one at the moment) at build time.
The docker build ARGS available are:

  - NPM_PRIVATE_REGISTRY_URL (https://myregistry.io/)
  - NPM_PRIVATE_REGISTRY_SCOPE (@myscope)
  - NPM_PRIVATE_REGISTRY_TOKEN (supersecret)

All args are optional, depending on your registry setup you may need only URL or more.

The options shown will create during build (and cleared after) a ~/.npmrc file with:
~~~bash
@myscope:registry=https://myregistry.io/
//myregistry.io/:_authToken=supersecret
~~~

#### Create a Dockerfile to build your app

~~~dockerfile
FROM plitex/meteord:onbuild
~~~
#### Build (using docker build)

~~~shell
$ docker build \
--build-arg NPM_PRIVATE_REGISTRY_URL=http://myregistry.io/ \
--build-arg NPM_PRIVATE_REGISTRY_SCOPE=@scope \
--build-arg NPM_PRIVATE_REGISTRY_TOKEN=supersecret -t my-app-image .
~~~

#### Build (using docker-compose)
docker-compose.yml

~~~yaml
dashboard:
  build:
    context: .
    args:
      - NPM_PRIVATE_REGISTRY_URL=http://myregistry.io/
      - NPM_PRIVATE_REGISTRY_SCOPE=@scope
      - NPM_PRIVATE_REGISTRY_TOKEN=supersecret
  ports:
   - "80:80"
  links:
   - mongo
  environment:
   - MONGO_URL=mongodb://mongo/yourapp
   - ROOT_URL=http://yourapp.com
   - MAIL_URL=smtp://some.mailserver.com:25

mongo:
  image: mongo:latest
~~~

Build
~~~shell
$ docker-compose up
~~~

## Known Issues

#### Spiderable Not Working (But, have a fix)

There are some issues when running spiderable inside a Docker container. For that, check this issue: https://github.com/meteor/meteor/issues/2429

Fortunately, there is a fix. Simply use [`ongoworks:spiderable`](https://github.com/ongoworks/spiderable) instead the official package.

#### Container won't start on Joyent's Triton infrastructure

There's currently (2015-07-18) an issue relating to how the command or entry point is parsed, so containers won't boot using the 'docker run' commands as above.

Instead, Joyent support has suggested the following workaround until their fix can be rolled out.

~~~shell
docker run -d \
    -e ROOT_URL=http://yourapp.com \
    -e MONGO_URL=mongodb://url \
    -e MONGO_OPLOG_URL=mongodb://oplog_url \
    -p 80:80 \
    --entrypoint=bash \
    yourname/app \
    /opt/meteord/run_app.sh
~~~
