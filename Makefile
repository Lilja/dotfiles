dotdrop:
	pip install dotdrop

install-win:
	export DOTDROP_TMPDIR=~/.cache/dotdrop && source dotbin/XDG.sh && dotdrop install --profile windows --cfg config.yaml

install: dotdrop
	./dotbin/XDG.sh && dotdrop install --profile nix --cfg config.yaml
