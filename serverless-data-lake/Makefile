install:
	pip install --upgrade pip && pip install -r requirements.txt

format:
	black *.py

lint:
	ruff *.py

execute: install format lint
