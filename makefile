VERSION ?= latest

build:
	cd sst-frontend; yarn install
	cd sst-frontend; yarn build
	cd sst-frontend; cp -r build ../sst-backend/frontend
	docker build --file=Dockerfile --no-cache --tag=aviatrix/sandbox-starter:${VERSION} .

clean:
	docker container rm $$(docker stop $$(docker ps -a -q)); docker rmi -f $$(docker images -qa aviatrix/sandbox-starter); docker volume rm TF

push:
	docker push aviatrix/sandbox-starter:${VERSION}

run:
	docker volume create TF
	docker run -v TF:/root -p 5000:5000 -d aviatrix/sandbox-starter:${VERSION}
