.PHONY: up down build test test-load lint clean

up:
	docker compose up -d

down:
	docker compose down -v

build:
	docker compose build

test:
	docker compose run --rm api pytest tests/ -v

test-load:
	./scripts/simulate_traffic.sh

lint:
	cd backend && ruff check . && ruff format --check .
	shellcheck scripts/*.sh

clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type d -name ".pytest_cache" -exec rm -rf {} +
