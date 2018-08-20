## Building Proj4 with JNI
The most recent version of [OSGeo/proj.4](https://github.com/OSGeo/proj.4) may work better, but last time I tried to build it I couldn't get JNI to work properly with my Docker files.

### Mac
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
