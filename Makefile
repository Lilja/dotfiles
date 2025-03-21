dotdrop:
	which dotdrop || brew install dotdrop

extras:
	which brew && xargs brew install < brew.txt || echo "brew not found"

.PHONY: install
install: dotdrop
	./dotbin/XDG.sh && dotdrop install --profile nix --cfg config.yaml

install-wsl: install extras
	./dotbin/XDG.sh && dotdrop install --profile wsl --cfg config.yaml

