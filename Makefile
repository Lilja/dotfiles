dotdrop:
	pip install dotdrop --upgrade

install: dotdrop
	./dotbin/XDG.sh && dotdrop install --profile nix --cfg config.yaml

install-wsl: install
	./dotbin/XDG.sh && dotdrop install --profile wsl --cfg config.yaml
