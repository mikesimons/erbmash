FROM golang

RUN apt-get update && apt-get install -y libyaml-dev ruby bison upx-ucl
ENV CGO_LDFLAGS="-lyaml"
WORKDIR /go/src/github.com/mikesimons/templateer
CMD [ "/bin/bash", "-c", "[[ ! -z $CLEAN ]] && make clean; make templateer" ]
