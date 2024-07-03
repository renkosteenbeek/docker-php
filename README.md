# Build & push
`docker buildx build --push --tag renkosteenbeek/php:8.3 --platform linux/arm64/v7,linux/arm64/v8,linux/amd64 .`

# Build only
`docker buildx build --tag renkosteenbeek/php:8.3 --platform linux/arm64/v7,linux/arm64/v8,linux/amd64 .`

# php settings
default.ini is altijd actief.

php.ini-production of development zijn standaard niet actief. Deze kunnen dmv een entrypoint beschikbaar gemaakt worden op basis van de context. 