VERSION ?= 1.4.2

build:
	sed -i'' -e 's+version = ".*"+version = "${VERSION}"+g' sst-frontend/src/components/app-bar/index.tsx
	cd sst-frontend; yarn install
	cd sst-frontend; yarn build
	cd sst-frontend; cp -r build ../sst-backend/frontend
	docker build --file=Dockerfile --no-cache --tag=aviatrix/sandbox-starter:${VERSION} .

clean:
	docker container rm $$(docker stop $$(docker ps -a -q)); docker rmi -f $$(docker images -qa aviatrix/sandbox-starter); docker volume rm TF; docker system prune -f

push:
	docker push aviatrix/sandbox-starter:${VERSION}

run:
	docker volume create TF
	docker run -v TF:/root -p 5001:5000 -d aviatrix/sandbox-starter:${VERSION}

run-latest:
	docker volume create TF
	docker run -v TF:/root -p 5001:5000 -d aviatrix/sandbox-starter:latest

release:
	docker tag aviatrix/sandbox-starter:${VERSION} aviatrix/sandbox-starter:latest
	docker push aviatrix/sandbox-starter:latest

run-m1:
	docker volume create TF
	docker run --platform linux/amd64 -v TF:/root -p 5001:5000 -d aviatrix/sandbox-starter:${VERSION}

build-m1:
	sed -i'' -e 's+version = ".*"+version = "${VERSION}"+g' sst-frontend/src/components/app-bar/index.tsx
	cd sst-frontend; yarn install
	cd sst-frontend; yarn build
	cd sst-frontend; cp -r build ../sst-backend/frontend
	docker build --platform linux/amd64 --file=Dockerfile --no-cache --tag=aviatrix/sandbox-starter:${VERSION} .
