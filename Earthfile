VERSION --try 0.7
#ARG --global REGISTRY=registry.harbor.kinetica.com/kineticadevcloud
ARG --global REGISTRY=kineticadevcloud

ARG --global PACKAGE_NAME=kinetica-operators

FROM busybox:latest

build-helm-package:
  ARG --required VERSION
  FROM alpine/helm:3.14.1

  RUN mkdir /package
  COPY --dir ${PACKAGE_NAME} /package/.
  WORKDIR /package
  RUN helm package "${PACKAGE_NAME}" --version "${VERSION}"

  SAVE ARTIFACT ${PACKAGE_NAME}-${VERSION}.tgz

# NOTE that this will completely overwrite the created timestamps on all charts
build-helm-index:
  FROM alpine/helm:3.14.1
  
  # Rebuild the index
  RUN mkdir /repo
  COPY docs/*.tgz /repo/.
  WORKDIR /repo
  RUN helm repo index --url https://kineticadb.github.io/charts/ .
  
  SAVE ARTIFACT index.yaml

local-helm-index:
  BUILD +build-helm-index
  LOCALLY
  COPY  (+build-helm-index/index.yaml) ./docs/.

add-package-to-helm-image:
  FROM alpine/helm:3.14.1
  ARG --required VERSION

  # Rebuild the index
  RUN mkdir /repo
  COPY docs/${PACKAGE_NAME}-${VERSION}.tgz /repo/.
  COPY docs/index.yaml /oldindex.yaml
  WORKDIR /repo
  RUN helm repo index --merge /oldindex.yaml --url https://kineticadb.github.io/charts/ .

  SAVE ARTIFACT index.yaml

local-helm-package:
  ARG --required VERSION
  BUILD +build-helm-package
  LOCALLY
  COPY  (+build-helm-package/${PACKAGE_NAME}-${VERSION}.tgz) ./docs/.
  BUILD +add-package-to-helm-image
  COPY  (+add-package-to-helm-image/index.yaml) ./docs/.

publish:
  FROM python:3.12
  RUN mkdir ~/.ssh && chmod 600 ~/.ssh && ssh-keyscan -H github.com >> ~/.ssh/known_hosts
  COPY ./mkdocs-requirements.txt /requirements.txt
  RUN pip install -r /requirements.txt
  COPY --dir . /publish
  WORKDIR /publish
  RUN --ssh mkdocs gh-deploy
