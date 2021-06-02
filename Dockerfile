ARG DOCKER_IMAGE=alpine:latest
FROM $DOCKER_IMAGE AS builder

RUN apk add --no-cache gcc g++ bison flex make musl-dev git \
	&& git clone --recurse-submodules https://github.com/arnoldrobbins/pcc-revived.git

WORKDIR /pcc-revived/pcc-libs
RUN ./configure --prefix=/tmp/pcc && make -j && make install
WORKDIR /pcc-revived/pcc
RUN ./configure --prefix=/tmp/pcc && make -j && make install


ARG DOCKER_IMAGE=alpine:latest
FROM $DOCKER_IMAGE AS runtime

LABEL author="Bensuperpc <bensuperpc@gmail.com>"
LABEL mantainer="Bensuperpc <bensuperpc@gmail.com>"

ARG VERSION="1.0.0"
ENV VERSION=$VERSION

RUN apk add --no-cache musl-dev make

COPY --from=builder /tmp/pcc /usr/local/pcc
ENV PATH="/usr/local/pcc/bin:${PATH}"

ENV CC=/usr/local/bin/pcc \
	CXX=/usr/local/bin/p++ \
	CPP=/usr/local/bin/pcpp 

WORKDIR /usr/src/myapp

CMD ["pcc", "-h"]

LABEL org.label-schema.schema-version="1.0" \
	  org.label-schema.build-date=$BUILD_DATE \
	  org.label-schema.name="bensuperpc/pcc-revived" \
	  org.label-schema.description="build pcc-revived compiler" \
	  org.label-schema.version=$VERSION \
	  org.label-schema.vendor="Bensuperpc" \
	  org.label-schema.url="http://bensuperpc.com/" \
	  org.label-schema.vcs-url="https://github.com/Bensuperpc/docker-pcc-revived" \
	  org.label-schema.vcs-ref=$VCS_REF \
	  org.label-schema.docker.cmd="docker build -t bensuperpc/pcc-revived -f Dockerfile ."

