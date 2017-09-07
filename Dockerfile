FROM openjdk:8u141-jdk-slim

# Install Proj4
# https://github.com/OSGeo/proj.4/blob/57a07c119ae08945caa92b29c4b427b57f1f728d/Dockerfile
# Setup build env
RUN mkdir /build
RUN apt update && \
    apt install -y git \
    automake \
    autoconf \
    libtool \
    build-essential \
    make

RUN export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")

# there is a lot of work to do here that cna be understood from the Travis build scripts.
# TODO vertical datum support
#RUN mkdir /vdatum \
#    && cd /vdatum \
#    && wget http://download.osgeo.org/proj/vdatum/usa_geoid2012.zip && unzip -j -u usa_geoid2012.zip -d /usr/share/proj \
#    && wget http://download.osgeo.org/proj/vdatum/usa_geoid2009.zip && unzip -j -u usa_geoid2009.zip -d /usr/share/proj \
#    && wget http://download.osgeo.org/proj/vdatum/usa_geoid2003.zip && unzip -j -u usa_geoid2003.zip -d /usr/share/proj \
#    && wget http://download.osgeo.org/proj/vdatum/usa_geoid1999.zip && unzip -j -u usa_geoid1999.zip -d /usr/share/proj \
#    && wget http://download.osgeo.org/proj/vdatum/vertcon/vertconc.gtx && mv vertconc.gtx /usr/share/proj \
#    && wget http://download.osgeo.org/proj/vdatum/vertcon/vertcone.gtx && mv vertcone.gtx /usr/share/proj \
#    && wget http://download.osgeo.org/proj/vdatum/vertcon/vertconw.gtx && mv vertconw.gtx /usr/share/proj \
#    && wget http://download.osgeo.org/proj/vdatum/egm96_15/egm96_15.gtx && mv egm96_15.gtx /usr/share/proj \
#    && wget http://download.osgeo.org/proj/vdatum/egm08_25/egm08_25.gtx && mv egm08_25.gtx /usr/share/proj \
#    && rm -rf /vdatum

#TODO there should be a release checkout
WORKDIR /opt/src
RUN git clone https://github.com/OSGeo/proj.4.git \
    && cd proj.4 \
    && ./autogen.sh \
    && CFLAGS=-I$JAVA_HOME/include/linux ./configure --with-jni=$JAVA_HOME/include --prefix=/usr/local \
    && make -j 8 \
    && make install
