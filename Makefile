IMAGE_NAME=akester/trunk-recorder

build-x86: init
	packer build --only=docker.tr-amd64 .

build-arm: init
	packer build --only=docker.tr-arm64 .

push-x86: login
	docker push $(IMAGE_NAME):tr-amd64-$(CI_COMMIT_BRANCH)

push-arm: login
	docker push $(IMAGE_NAME):tr-arm64-$(CI_COMMIT_BRANCH)

init:
	packer init .

login:
	echo '${DOCKER_TOKEN}' | docker login --username akester --password-stdin

push-manifest: login
	docker manifest create $(IMAGE_NAME):$(CI_COMMIT_BRANCH) $(IMAGE_NAME):tr-amd64-$(CI_COMMIT_BRANCH) $(IMAGE_NAME):tr-arm64-$(CI_COMMIT_BRANCH)
	docker manifest annotate $(IMAGE_NAME):$(CI_COMMIT_BRANCH) $(IMAGE_NAME):tr-arm64-$(CI_COMMIT_BRANCH) --os linux --arch arm64
	docker manifest push --purge $(IMAGE_NAME):$(CI_COMMIT_BRANCH)
