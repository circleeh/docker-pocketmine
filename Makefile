default: test

# Build Docker image
build: docker_build output

# Build and push Docker image
release: docker_build docker_push output

# Image and binary can be overidden with env vars.
DOCKER_IMAGE ?= circleeh/pocketmine
BINARY ?= .

define GetFromJson
$(shell curl -s "https://jenkins.pmmp.io/job/PocketMine-MP/$(1)/artifact/build_info.json" | jq -r ".$(2)")
endef

POCKETMINE_CHANNEL ?= Alpha
POCKETMINE_RELEASE ?= $(call GetFromJson,${POCKETMINE_CHANNEL},phar_name)
POCKETMINE_RELEASE_SHORT ?= $(call GetFromJson,${POCKETMINE_CHANNEL},base_version)-$(call GetFromJson,${POCKETMINE_CHANNEL},build_number)
POCKETMINE_CHANNEL_BETA ?= Beta
POCKETMINE_RELEASE_BETA ?= $(call GetFromJson,${POCKETMINE_CHANNEL_BETA},phar_name)
POCKETMINE_RELEASE_SHORT_BETA ?= $(call GetFromJson,${POCKETMINE_CHANNEL_BETA},base_version)-$(call GetFromJson,${POCKETMINE_CHANNEL_BETA},build_number)
POCKETMINE_CHANNEL_STABLE ?= Stable
POCKETMINE_RELEASE_STABLE ?= $(call GetFromJson,${POCKETMINE_CHANNEL_STABLE},phar_name)
POCKETMINE_RELEASE_SHORT_STABLE ?= $(call GetFromJson,${POCKETMINE_CHANNEL_STABLE},base_version)-$(call GetFromJson,${POCKETMINE_CHANNEL_STABLE},build_number)

# Get the latest commit.
GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))

# Get the version number from the code
CODE_VERSION = $(strip $(shell cat VERSION))

# Find out if the working directory is clean
GIT_NOT_CLEAN_CHECK = $(shell git status --porcelain)
ifneq (x$(GIT_NOT_CLEAN_CHECK), x)
DOCKER_TAG_SUFFIX = "-dirty"
endif

# If we're releasing to Docker Hub, and we're going to mark it with the latest tag, it should exactly match a version release
ifeq ($(MAKECMDGOALS),release)
# Use the version number as the release tag.
DOCKER_TAG = $(CODE_VERSION)

ifndef CODE_VERSION
$(error You need to create a VERSION file to build a release)
endif

# See what commit is tagged to match the version
VERSION_COMMIT = $(strip $(shell git rev-list $(CODE_VERSION) -n 1 | cut -c1-7))
ifneq ($(VERSION_COMMIT), $(GIT_COMMIT))
$(error echo You are trying to push a build based on commit $(GIT_COMMIT) but the tagged release version is $(VERSION_COMMIT))
endif

# Don't push to Docker Hub if this isn't a clean repo
ifneq (x$(GIT_NOT_CLEAN_CHECK), x)
$(error echo You are trying to release a build based on a dirty repo)
endif

else
# Add the commit ref for development builds. Mark as dirty if the working directory isn't clean
DOCKER_TAG = $(CODE_VERSION)-$(GIT_COMMIT)$(DOCKER_TAG_SUFFIX)
endif

docker_build_alpha:
	# Build Docker image
	docker build \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg VERSION=$(CODE_VERSION) \
  --build-arg VCS_URL=`git config --get remote.origin.url` \
  --build-arg VCS_REF=$(GIT_COMMIT) \
  --build-arg POCKETMINE_CHANNEL=$(POCKETMINE_CHANNEL) \
  --build-arg POCKETMINE_RELEASE=$(POCKETMINE_RELEASE) \
	-t $(DOCKER_IMAGE):$(POCKETMINE_RELEASE_SHORT) .

docker_build_beta:
	docker build \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg VERSION=$(CODE_VERSION) \
  --build-arg VCS_URL=`git config --get remote.origin.url` \
  --build-arg VCS_REF=$(GIT_COMMIT) \
  --build-arg POCKETMINE_CHANNEL=$(POCKETMINE_CHANNEL_BETA) \
  --build-arg POCKETMINE_RELEASE=$(POCKETMINE_RELEASE_BETA) \
	-t $(DOCKER_IMAGE):$(POCKETMINE_RELEASE_SHORT_BETA) .

docker_build_stable:
	docker build \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg VERSION=$(CODE_VERSION) \
  --build-arg VCS_URL=`git config --get remote.origin.url` \
  --build-arg VCS_REF=$(GIT_COMMIT) \
  --build-arg POCKETMINE_CHANNEL=$(POCKETMINE_CHANNEL_STABLE) \
  --build-arg POCKETMINE_RELEASE=$(POCKETMINE_RELEASE_STABLE) \
	-t $(DOCKER_IMAGE):$(POCKETMINE_RELEASE_SHORT_STABLE) .

docker_push_alpha:
	docker tag $(DOCKER_IMAGE):$(POCKETMINE_RELEASE_SHORT) $(DOCKER_IMAGE):alpha
	# Push to DockerHub
	docker push $(DOCKER_IMAGE):$(POCKETMINE_RELEASE_SHORT)
	docker push $(DOCKER_IMAGE):alpha

docker_push_beta:
	docker tag $(DOCKER_IMAGE):$(POCKETMINE_RELEASE_SHORT_BETA) $(DOCKER_IMAGE):beta
	docker push $(DOCKER_IMAGE):$(POCKETMINE_RELEASE_SHORT_BETA)
	docker push $(DOCKER_IMAGE):beta

docker_push_stable:
	# Tag image as latest
	docker tag $(DOCKER_IMAGE):$(POCKETMINE_RELEASE_SHORT_STABLE) $(DOCKER_IMAGE):latest
	docker tag $(DOCKER_IMAGE):$(POCKETMINE_RELEASE_SHORT_STABLE) $(DOCKER_IMAGE):stable
	docker push $(DOCKER_IMAGE):$(POCKETMINE_RELEASE_SHORT_STABLE)
	docker push $(DOCKER_IMAGE):latest
	docker push $(DOCKER_IMAGE):stable

output:
	@echo Docker Image: $(DOCKER_IMAGE):$(POCKETMINE_RELEASE_SHORT_STABLE)
