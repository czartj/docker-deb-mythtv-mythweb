default: docker_build

docker_build:
	@docker build -t czartj/docker-deb-mythtv-mythweb:latest --build-arg BUILD_DATE=`date -u +"%Y-%m-%dTH:%M:%SZ"` .
