build:
	@docker compose build

bash:
	@docker compose run --service-ports --rm acerola01 bash

up:
	@docker compose up

down:
	@docker compose down --remove-orphans
