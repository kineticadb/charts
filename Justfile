image-version := "0.0.1"
image-name := "k8s-mkdocs"
image-registry := "kinetica.azurecr.io/dev"

docker-image push="true":
	docker build -f Dockerfile.mkdocs . $(if [ "{{ push }}" = "true" ]; then echo -n "--push"; fi) -t {{ image-registry }}/{{ image-name }}:{{ image-version }}

serve-docs: docker-image
	docker run --rm -it -p 8000:8000 -v ${PWD}:/docs {{ image-registry }}/{{ image-name }}:{{ image-version }}
