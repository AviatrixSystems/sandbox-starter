Aviatrix Sandbox Starter Backend
===========

this is the repo for aviatrix sandbox starter api's built using flask restful. 

Requirements
------------

- Flask (`pip install flask`).
- Flask-RESTful (`pip install Flask-RESTful`).


Installation
------------

You can create a virtual environment and install the required packages with the following commands:

    $ virtualenv venv
    $ . venv/bin/activate
    (venv) $ pip install -r requirements.txt

Running  backend using Docker
--------------------

Instructions
------------
Install Docker if you don't already have it: https://docs.docker.com/get-docker/.

Build the image:
```docker build -t sandbox-starter --file Dockerfile .```

Start the container:
```
docker volume create TF
docker run -v TF:/root -p 5000:5000 -d sandbox-starter
```

Launch Aviatrix Sandbox Starter by navigating to http://localhost:5000/


