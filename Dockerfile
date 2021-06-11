FROM alpine:3.13.5

ENV TERRAFORM_VERSION=1.0.0

# Dependencies. #Terraform # Awscli # make directory
RUN apk update && \
    apk add curl jq python3 py3-pip bash ca-certificates git openssl unzip wget openssh-keygen && \
    cd /tmp && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin && \
    pip3 install awscli && pip3 install requests urllib3 && pip3 install git+git://github.com/HR/github-clone#egg=ghclone && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf /var/tmp/*

# Aviatrix Sandbox-Starter.
ADD     sandbox-starter/controller /root/controller
ADD     sandbox-starter/controller-govcloud /root/controller-govcloud
ADD	sandbox-starter/mcna /root/mcna
ADD	sandbox-starter/mcna-govcloud /root/mcna-govcloud
ADD	sandbox-starter/sandbox_starter.sh /root/
ADD	sandbox-starter/.plane /root/
ADD	sandbox-starter/.eagle /root/

# SST backend.
ADD	sandbox-starter/sandbox_starter_web.sh /root/
ADD sst-backend/requirements.txt /root/requirements.txt
RUN pip3 install -r /root/requirements.txt 
ADD sst-backend /root/

# Misc. configuration
RUN	mkdir -p /root/.emacs.d/lisp
ADD	config/terraform-mode.el /root/.emacs.d/lisp
ADD	config/hcl-mode.el /root/.emacs.d/lisp
ADD	config/dotemacs /root/.emacs

WORKDIR /root
CMD python3 app.py
