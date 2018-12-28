ARG JDK_TAG=11-jdk-slim
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
    ant -v && \
    mv /opt/src/proj.4/jniwrap/out/proj.jar /usr/local/lib/

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


## Production build
FROM openjdk:${JRE_TAG}

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    rm -rf /var/lib/apt

WORKDIR /usr/local
COPY --from=builder /usr/local .
RUN export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")

ENV PROJ_LIB=/usr/local/share/proj

RUN /sbin/ldconfig
