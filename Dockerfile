FROM openjdk:8u141-jdk-slim as builder
RUN apt update && \
    apt install -y git \
    automake \
    autoconf \
    libtool \
    build-essential \
    make \
    wget

WORKDIR /opt/src
RUN git clone https://github.com/OSGeo/proj.4.git && \
    rm -rf /opt/src/proj.4/docs && \
    rm -rf /opt/src/proj.4/.git

# Horizontal datums to improve test results
WORKDIR /opt/src/proj.4/nad
RUN wget -qO- -O tmp.zip http://download.osgeo.org/proj/proj-datumgrid-1.6.zip && \
    unzip -o tmp.zip && \
    rm tmp.zip && \
    wget http://download.osgeo.org/proj/vdatum/egm96_15/egm96_15.gtx

RUN export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")
WORKDIR /opt/src/proj.4
RUN ./autogen.sh && \
    CFLAGS=-I$JAVA_HOME/include/linux ./configure --with-jni=$JAVA_HOME/include --prefix=/usr/local && \
    make -j 8 && \
    make install && \
    make check && \
    cd src && \
    make multistresstest && \
    make test228

ENV PROJ_LIB=/opt/src/proj.4/nad
WORKDIR /opt/src/proj.4/src
RUN ./multistresstest
WORKDIR /opt/src/proj.4/nad
RUN for file in ./test*; do $file 2>/dev/null; done

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


FROM openjdk:8u141-jdk-slim


RUN apt update && \
    apt install -y git \
    automake \
    autoconf \
    libtool \
    build-essential \
    make

RUN export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")

WORKDIR /opt/src
COPY --from=builder /opt/src/proj.4 .

##TODO there should be a release checkout
#WORKDIR /opt/src
#RUN git clone https://github.com/OSGeo/proj.4.git \
#    && cd proj.4 \
#    && ./autogen.sh \
#    && CFLAGS=-I$JAVA_HOME/include/linux ./configure --with-jni=$JAVA_HOME/include --prefix=/usr/local \
#    && make -j 8 \
#    && make install



# https://github.com/OSGeo/proj.4/blob/57a07c119ae08945caa92b29c4b427b57f1f728d/Dockerfile
