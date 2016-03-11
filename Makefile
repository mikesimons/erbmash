MRUBY_COMMIT ?= 22464fe5a0a10f2b077eaba109ce1e912e4a77de
GO_MRUBY_PATH ?= vendor/github.com/mikesimons/go-mruby
MRUBY_PATH = ${GO_MRUBY_PATH}/vendor/mruby

all:
	docker run -i -v ${GOPATH}:/go -e http_proxy=${http_proxy} -e https_proxy=${https_proxy} --net=host -t templateer-build

templateer: libmruby.a
	go build --ldflags '-extldflags "-static"'

clean:
	rm -rf ${GO_MRUBY_PATH}/vendor
	rm -f libmruby.a

libmruby.a: $(MRUBY_PATH)
	cp build_config.rb ${MRUBY_PATH}
	cd ${MRUBY_PATH} && ${MAKE}
	cp ${MRUBY_PATH}/build/host/lib/libmruby.a ${GO_MRUBY_PATH}
	cp ${MRUBY_PATH}/build/host/lib/libmruby.a .

$(MRUBY_PATH):
	git clone https://github.com/mruby/mruby.git ${MRUBY_PATH} || true
	cd ${MRUBY_PATH} && git reset --hard && git clean -fdx
	cd ${MRUBY_PATH} && git checkout ${MRUBY_COMMIT}

.PHONY: all templateer clean test
