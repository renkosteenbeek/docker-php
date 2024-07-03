# Build & push
`docker buildx build --push --tag renkosteenbeek/php:8.3 --platform linux/arm64/v7,linux/arm64/v8,linux/amd64 .`

# Build only
`docker buildx build --tag renkosteenbeek/php:8.3 --platform linux/arm64/v7,linux/arm64/v8,linux/amd64 .`