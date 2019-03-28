default: list

DOCKER_IMAGE ?= edofede/nginx-php-fpm

ARCHS ?= amd64 arm32v6 arm32v7 i386 ppc64le
BASEIMAGE_BRANCH ?= 2.0

GITHUB_TOKEN ?= "NONE"

ARCH ?= amd64
BRANCH ?= $(shell git branch |grep \* |cut -d ' ' -f2)
DOCKER_TAG = $(shell echo $(BRANCH) |sed 's/^v//')
GIT_COMMIT ?= $(strip $(shell git rev-parse --short HEAD))


.PHONY: list git_push git_fix_permission output build debug run test test_all clean docker_push docker_push_latest


list:
	@printf "# Available targets: \\n"
	@cat Makefile |sed '1d' |cut -d ' ' -f1 |grep : |grep -v -e '\t' -e '\.' |cut -d ':' -f1
	@printf "\\n# Syntax: \\n"
	@printf "\\tmake git_push \\ \\n\\t\\tCOMMENT=\"<commit description>\" \\ \\n\\t\\t[BRANCH=<GitHub branch> (default: \`git branch |grep \* |cut -d ' ' -f2\`)]\\n"
	@printf "\\tmake git_fix_permission \\n"
	@printf "\\tmake output \\ \\n\\t\\t[BRANCH=<GitHub branch> (default: \`git branch |grep \* |cut -d ' ' -f2\`)] \\n"
	@printf "\\tmake build \\ \\n\\t\\t[BRANCH=<Git destination branch> (default: \`git branch |grep \* |cut -d ' ' -f2\`)] \\ \\n\\t\\t[ARCHS=<List of architectures to build> (default: amd64 arm32v6 arm32v7 i386 ppc64le)] \\ \\n\\t\\t[ALPINE_BRANCH=<Alpine linux version> (default: 3.9.2)] \\ \\n\\t\\t[GIT_COMMIT=<Git commit sha> (default: git rev-parse --short HEAD)] \\ \\n\\t\\t[GITHUB_TOKEN=<Github auth token for API>] \\n"
	@printf "\\tmake run \\ \\n\\t\\t[BRANCH=<GitHub branch> (default: \`git branch |grep \* |cut -d ' ' -f2\`)] \\n"
	@printf "\\tmake debug \\ \\n\\t\\t[BRANCH=<GitHub branch> (default: \`git branch |grep \* |cut -d ' ' -f2\`)] \\n"
	@printf "\\tmake test \\ \\n\\t\\t[BRANCH=<GitHub branch> (default: \`git branch |grep \* |cut -d ' ' -f2\`)] \\n"
	@printf "\\tmake test_all \\ \\n\\t\\t[BRANCH=<GitHub branch> (default: \`git branch |grep \* |cut -d ' ' -f2\`)] \\ \\n\\t\\t[ARCHS=<List of architectures to build> (default: amd64 arm32v6 arm32v7 i386 ppc64le)] \\n"
	@printf "\\tmake clean \\n"
	@printf "\\tmake docker_push \\ \\n\\t\\t[BRANCH=<GitHub branch> (default: \`git branch |grep \* |cut -d ' ' -f2\`)] \\n"
	@printf "\\tmake docker_push_latest \\ \\n\\t\\t[BRANCH=<GitHub branch> (default: \`git branch |grep \* |cut -d ' ' -f2\`)] \\n"


git_push:
ifndef COMMENT
	@printf "Add comment to current commit: \\nSyntax: make git_push COMMENT=\"xxxx\"\\n"
else
	@git add .
	@git commit -S -m "$(COMMENT)"
	@git push origin $(BRANCH)
endif


git_fix_permission:
	@find . -type f ! -path '*/.git/*' ! -name '.DS_Store' -exec xattr -c {} \;
	@find . -type f ! -path '*/.git/*' ! -name '.DS_Store' ! -path '*/build_tmp/*' -perm +111 -exec git update-index --chmod=+x {} \;
	@find . -type f ! -path '*/.git/*' ! -name '.DS_Store' ! -path '*/build_tmp/*' ! -perm +111 -exec git update-index --chmod=-x {} \;


output:
	@echo Docker Image: "$(DOCKER_IMAGE)":"$(DOCKER_TAG)"


build:
	@$(foreach ARCH,$(ARCHS), \
		scripts/build.sh -i $(DOCKER_IMAGE) -t $(DOCKER_TAG) \
			-a $(ARCH) \
			-b $(BASEIMAGE_BRANCH) \
			-v $(BRANCH) \
			-r $(GIT_COMMIT) \
			-g $(GITHUB_TOKEN) ;\
	)
	

run:
	@docker run --rm \
		--publish-all \
		$(DOCKER_IMAGE):$(DOCKER_TAG) &


debug:
	@docker run --rm -ti \
		$(DOCKER_IMAGE):$(DOCKER_TAG) \
		/bin/bash


test:
	@./scripts/testWeb.sh $(DOCKER_TAG)-$(ARCH)


test_all:
	@$(foreach ARCH,$(ARCHS), \
		./scripts/testWeb.sh $(DOCKER_TAG)-$(ARCH); \
	)


clean:
	@docker stop $(shell docker ps -q `docker image ls -q $(DOCKER_IMAGE) |sed 's/.*/ --filter ancestor=&/'`) || exit 0
	@docker rm $(shell docker ps -a -q `docker image ls -q $(DOCKER_IMAGE) |sed 's/.*/ --filter ancestor=&/'`) || exit 0
	@docker image rm $(shell docker image ls -a -q $(DOCKER_IMAGE)) || exit 0
	@docker image prune -f


docker_push:
	@./scripts/pushDockerHub.sh -i $(DOCKER_IMAGE) -t $(DOCKER_TAG)


docker_push_latest:
	@./scripts/pushDockerHub.sh -i $(DOCKER_IMAGE) -t $(DOCKER_TAG) -l
