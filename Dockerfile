FROM openjdk:8u141-jdk-slim as builder

# Test and CI builder
RUN apt update && \
    apt install -y git \
    automake \
    autoconf \
    libtool \
    build-essential \
    make \
    wget \
    ant && \
    rm -rf /var/lib/apt

WORKDIR /opt/src/proj.4

COPY ./ ./

RUN export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")

# CC="ccache gcc" CFLAGS="-g -Wfloat-conversion -Wall -Wextra -Werror -Wunused-parameter -Wmissing-prototypes -Wmissing-declarations -Wformat -Werror=format-security -Wshadow -O2"
RUN ./autogen.sh && \
    CFLAGS=-I$JAVA_HOME/include/linux ./configure --with-jni=$JAVA_HOME/include --prefix=/usr/local && \
    make -j 8 && \
    make install && \
    cd jniwrap && \
    ant && \
    mv /opt/src/proj.4/jniwrap/libs/jproj.jar /usr/local/lib/

# Horizontal datums to improve test results
WORKDIR /usr/local/share/proj
RUN wget -qO- -O tmp.zip http://download.osgeo.org/proj/proj-datumgrid-1.6.zip && \
    unzip -o tmp.zip && \
    rm tmp.zip && \
    wget http://download.osgeo.org/proj/vdatum/egm96_15/egm96_15.gtx

# TODO vertical datum support
#WORKDIR /vdatum
#RUN wget http://download.osgeo.org/proj/vdatum/usa_geoid2012.zip && unzip -j -u usa_geoid2012.zip -d /usr/local/share/proj \
#    && wget http://download.osgeo.org/proj/vdatum/usa_geoid2009.zip && unzip -j -u usa_geoid2009.zip -d /usr/local/share/proj \
#    && wget http://download.osgeo.org/proj/vdatum/usa_geoid2003.zip && unzip -j -u usa_geoid2003.zip -d /usr/local/share/proj \
#    && wget http://download.osgeo.org/proj/vdatum/usa_geoid1999.zip && unzip -j -u usa_geoid1999.zip -d /usr/local/share/proj \
#    && wget http://download.osgeo.org/proj/vdatum/vertcon/vertconc.gtx && mv vertconc.gtx /usr/local/share/proj \
#    && wget http://download.osgeo.org/proj/vdatum/vertcon/vertcone.gtx && mv vertcone.gtx /usr/local/share/proj \
#    && wget http://download.osgeo.org/proj/vdatum/vertcon/vertconw.gtx && mv vertconw.gtx /usr/local/share/proj \
#    && wget http://download.osgeo.org/proj/vdatum/egm96_15/egm96_15.gtx && mv egm96_15.gtx /usr/local/share/proj \
#    && wget http://download.osgeo.org/proj/vdatum/egm08_25/egm08_25.gtx && mv egm08_25.gtx /usr/local/share/proj \
#    && rm -rf /vdatum

ENV PROJ_LIB=/usr/local/share/proj
WORKDIR /opt/src/proj.4
RUN make check && \
    cd src && \
    make multistresstest && \
    make test228

#RUN ./multistresstest
WORKDIR /opt/src/proj.4/nad

RUN apt update && apt install -y python3
RUN apt-get install -y python3-pip
RUN apt-get install -y python3-dev

RUN pip3 install -v --user pyproj
WORKDIR /opt/src/proj.4/test/gigs
RUN python3 test_json.py --test conversion 5101.1-jhs.json 5101.4-jhs-etmerc.json 5105.2.json 5106.json 5108.json 5110.json 5111.1.json
RUN python3 test_json.py 5101.2-jhs.json 5101.3-jhs.json 5102.1.json 5103.1.json 5103.2.json 5103.3.json 5107.json 5109.json 5112.json 5113.json 5201.json 5208.json

## Production build
FROM openjdk:8u141-jdk-slim

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    rm -rf /var/lib/apt
#WORKDIR /opt/src
#COPY --from=builder /opt/src/proj.4 .
WORKDIR /usr/local
COPY --from=builder /usr/local .
RUN export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")

ENV PROJ_LIB=/usr/local/share/proj

RUN /sbin/ldconfig

