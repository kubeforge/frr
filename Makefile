all: build push

DOCKERREPO       := kubeforge/frr

build:
				docker build -t $(DOCKERREPO) -f Dockerfile .

push: build
			docker push $(DOCKERREPO)
