IMAGE ?= localhost/bees
PORT  ?= 4000

.PHONY: dev build run logs clean

dev:
	nix develop -c bash -c 'mix deps.get && mix run --no-halt'

build:
	podman build -t $(IMAGE) .

run:
	podman run --rm --name bees --env-file .env -e PORT=4000 -p $(PORT):4000 $(IMAGE)

logs:
	podman logs -f bees

clean:
	-podman rmi $(IMAGE)
	rm -rf _build deps
