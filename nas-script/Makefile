setup:
	poetry install

build: setup
	poetry run pyinstaller --onefile nas/nas.py
	cp dist/nas ../bin/nas
