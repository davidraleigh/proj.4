# Proj4 with JNI
The most recent version of [OSGeo/proj.4](https://github.com/OSGeo/proj.4) may work better, but last time I tried to build it I couldn't get JNI to work properly with my Docker files.

## Pull the Docker image
Pull the docker image with the [tag](https://hub.docker.com/r/echoparklabs/proj.4/tags/) appropriate to your Java environment. In this case I'm pulling the JDK Alpine image
```bash
docker pull echoparklabs/proj.4:8-jdk-alpine
```

## Building for Mac
After cloning the repo locally, you'll need to install some build tools. These can be installed with homebrew (I can't remember if `mozjpeg` is necessary, someone please try building without it and let me know):
```bash
brew reinstall libtool
brew reinstall mozjpeg
brew reinstall autoconf
brew reinstall automake
brew install ant
```

Change directories into the proj.4 directory and execute the following to build proj.4 and copy the proj.4 jar into `/usr/local/lib`:
```bash
export JAVA_HOME="$(/usr/libexec/java_home)"
CFLAGS=-I$JAVA_HOME/include/darwin ./configure --with-jni=$JAVA_HOME/include
make
make install
cd jniwrap
ant
cp ./jniwrap/libs/jproj.jar /usr/local/lib/
```

## Building your own Docker Image
The Docker images are based off of the [openjdk](https://hub.docker.com/_/openjdk/) images. You can build a jdk image or a jre image, you can use Java 8 or 10 (maybe 11, haven't tested), and you can use debian or alpine.

### Building Debian
To build the latest debian 8 jdk image:
```bash
docker build -t us.gcr.io/echoparklabs/proj.4:8-jdk-slim .
```
The latest debian 8 jre image
```bash
docker build --build-arg JRE_TAG=8-jre-slim -t echoparklabs/proj.4:8-jre-slim .
```
To build the latest debian 10 jdk:
```bash
docker build --build-arg JDK_TAG=10-jdk-slim -t echoparklabs/proj.4:10-jdk-slim .
```
To build the latest debian 10 jre:
```bash
docker build --build-arg JDK_TAG=10-jdk-slim --build-arg JRE_TAG=10-jre-slim \
       -t echoparklabs/proj.4:10-jdk-slim .
```


### Building Alpine
At this time, the resulting Alpine docker image is about 50% smaller than the slim debian images. The default Alpine image uses the `8-jdk-apline` image

To build the latest Alpine JDK 8 image:
```bash
docker build -t echoparklabs/proj.4:8-jdk-alpine -f Dockerfile.alpine .
```

To build the latest Alpine JRE image use the jre tag with a `--build-arg` (it will default to the latest JDK 8 alpine image):
```bash
docker build --build-arg JRE_TAG=8-jre-alpine \
       -t echoparklabs/proj.4:8-jre-alpine -f Dockerfile.alpine .
```


### Building with specific Debian JDK or JRE docker images:

To build a specific Alpine JDK 8 image use the `--build-arg`. For example if you wanted to build off of the `8u171-jdk-alpine3.8` openjdk image:
```bash
docker build --build-arg JDK_TAG=8u171-jdk-alpine3.8 \
       -t echoparklabs/proj.4:8u171-jdk-alpine3.8 -f Dockerfile.alpine .
```

And to build a specific jre image use the following `--build-args`. For example if you wanted to the `8u171-jre-alpine3.8`  you would need to also specifiy `8u171-jdk-alpine3.8` JDK:
```bash
docker build --build-arg JRE_TAG=8u171-jre-alpine3.8 \
       --build-arg JDK_TAG=8u171-jdk-alpine3.8 \
       -t echoparklabs/proj.4:8u171-jre-alpine3.8 -f Dockerfile.alpine .
```


