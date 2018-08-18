ARG JDK_TAG=8-jdk-slim
ARG JRE_TAG=${JDK_TAG}

FROM openjdk:${JDK_TAG} as builder

MAINTAINER David Raleigh <david@echoparklabs.io>

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
ARG FETCH_VERT=0
ENV VERT_DATUM=$FETCH_VERT
RUN /opt/src/proj.4/datum-installs.sh $FETCH_VERT

ENV PROJ_LIB=/usr/local/share/proj
WORKDIR /opt/src/proj.4
RUN make check && \
    cd src && \
# TODO move to testing
    make multistresstest && \
    make test228

#RUN ./multistresstest
#WORKDIR /opt/src/proj.4/nad

# TODO move to testing
RUN apt update && apt install -y python3
RUN apt-get install -y python3-pip
RUN apt-get install -y python3-dev

RUN pip3 install -v --user pyproj
WORKDIR /opt/src/proj.4/test/gigs
RUN python3 test_json.py --test conversion 5101.1-jhs.json 5101.4-jhs-etmerc.json 5105.2.json 5106.json 5108.json 5110.json 5111.1.json
RUN python3 test_json.py 5101.2-jhs.json 5101.3-jhs.json 5102.1.json 5103.1.json 5103.2.json 5103.3.json 5107.json 5109.json 5112.json 5113.json 5201.json 5208.json
# TODO move to testing


## Production build
FROM openjdk:${JRE_TAG}

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    rm -rf /var/lib/apt

WORKDIR /usr/local
COPY --from=builder /usr/local .
RUN export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")

ENV PROJ_LIB=/usr/local/share/proj

RUN /sbin/ldconfig
