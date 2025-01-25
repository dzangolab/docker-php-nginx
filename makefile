build:
	docker buildx build --platform linux/amd64,linux/arm64 -t dzangolab/docker-php-nginx:8.2 .
