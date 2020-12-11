setup:
	poetry install

build: setup
	poetry run pyinstaller --onefile nas/nas.py
	cp dist/nas ../bin/nas

build-nuitka:
	poetryn run python -m nuitka --standalone --mingw64 nas/nas.py
