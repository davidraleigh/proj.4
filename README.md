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
export PROJ_DIR=/usr/local/Cellar/proj/5.2.0
export JAVA_HOME="$(/usr/libexec/java_home)"
autoreconf -i
CFLAGS=-I$JAVA_HOME/include/darwin ./configure --with-jni=$JAVA_HOME/include --prefix=$PROJ_DIR
make -j 8
make install
cd jniwrap
ant -v
cp ./out/proj.jar $PROJ_DIR/lib/proj.jar
brew link proj
```

## Building your own Docker Image
The Docker images are based off of the [openjdk](https://hub.docker.com/_/openjdk/) images. You can build a jdk image or a jre image, you can use Java 8 or 10 (maybe 11, haven't tested), and you can use debian or alpine.

### Building Debian
To build the latest debian 11 jdk image:
```bash
docker build -t us.gcr.io/echoparklabs/proj.4:11-jdk-slim .
```
The latest debian 11 jre image
```bash
docker build --build-arg JRE_TAG=11-jre-slim -t echoparklabs/proj.4:11-jre-slim .
```


### Building Alpine
At this time, the resulting Alpine docker image is about 50% smaller than the slim debian images. The default Alpine image uses the `12-jdk-apline` image

To build the latest Alpine JDK 12 image:
```bash
docker build -t echoparklabs/proj.4:12-jdk-alpine -f Dockerfile.alpine .
```



