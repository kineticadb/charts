VERSION --try 0.7
#ARG --global REGISTRY=registry.harbor.kinetica.com/kineticadevcloud
ARG --global REGISTRY=kineticadevcloud

FROM busybox:latest

build-helm-package:
  ARG --required VERSION
  FROM alpine/helm:3.14.1

  RUN mkdir /package
  COPY --dir kinetica-operators /package/.
  WORKDIR /package
  RUN helm package kinetica-operators --version "${VERSION}"

  SAVE ARTIFACT kinetica-operators-${VERSION}.tgz

build-helm-index:
  FROM alpine/helm:3.14.1
  
  # Rebuild the index
  RUN mkdir /repo
  COPY docs/*.tgz /repo/.
  WORKDIR /repo
  RUN helm repo index --url https://kineticadb.github.io/charts/ .
  
  SAVE ARTIFACT index.yaml

local-helm-package:
  ARG --required VERSION
  BUILD +build-helm-package
  LOCALLY
  COPY  (+build-helm-package/kinetica-operators-${VERSION}.tgz) ./docs/.
  BUILD +local-helm-index

local-helm-index:
  BUILD +build-helm-index
  LOCALLY
  COPY  (+build-helm-index/index.yaml) ./docs/.

publish:
  FROM python:3.12
  RUN mkdir ~/.ssh && chmod 600 ~/.ssh && ssh-keyscan -H github.com >> ~/.ssh/known_hosts
  COPY ./mkdocs-requirements.txt /requirements.txt
  RUN pip install -r /requirements.txt
  COPY --dir . /publish
  WORKDIR /publish
  RUN --ssh mkdocs gh-deploy
