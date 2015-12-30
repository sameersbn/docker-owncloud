all: build

build:
	@docker build --tag=sameersbn/owncloud .

release: build
	@docker build --tag=sameersbn/owncloud:$(shell cat VERSION) .
