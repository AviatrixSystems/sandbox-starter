# sandbox-starter

Spin up cloud networks in minutes

## About

To learn about Sandbox Starter, visit its [Aviatrix Community space](https://community.aviatrix.com/t/g9hx9jh/aviatrix-sandbox-starter-tool-spin-up-cloud-networks-in-minutes)

## Prerequsites for local development

Building sandbox starter has several workstation or user prerequsites.

- The local workstation requires a [docker installation](https://docs.docker.com/get-docker/)
  - For macOS homebrew installation

    ```bash
    brew cask install docker
    ```

- Aws credentials for testing controller launch and transit deployment in AWS.
- Azure credentials for testing transit deployment and cross-cloud transit peering.
- An EC2 key pair in the Ohio (us-east-2) and N Virginia (us-east-1) regions.
- Subscription to the [Aviatrix metered software](https://aws.amazon.com/marketplace/pp/B08NTSDHKG) from the AWS Marketplace (Unless launching the controller as [BYOL](lauching-sst-with-the-byol-version-of-the-aviatrix-controller)).

## Building the sst docker image locally

To build the sst docker image, update the [makefile](./makefile) version variable and execute:

```bash
make build
```

## Launching the sst docker image locally

To run the sst docker image from a built `make build`, execute:

```bash
make run
```

## Removing the sst docker image locally

To start over and clean your system of built sst docker images, execute:

```bash
make clean
```

## Lauching the latest version of sst in AWS using terraform

To run the Sandbox Starter in AWS with a pre-built sst AMI using terraform:

```bash
git clone https://github.com/AviatrixSystems/sandbox-starter.git
cd ./sandbox-starter/infra-ami
```

Be sure to update [variables.tf](./infra-ami/variables.tf) to specify your region and ec2 keypair name. Then:

```bash
terraform init
terraform apply
```

The url for the sandbox starter is output from terraform.

## Lauching sst with the BYOL version of the Aviatrix controller

BYOL (bring your own license) is now a deployment option. Select `BYOL` from the `Controller License Type` dropdown (default is `Metered Platinum`).
