> [!CAUTION]
> **This Project is no longer actively maintained**

# sandbox-starter

Spin up cloud networks in minutes

## About

To learn about Sandbox Starter, visit its [Aviatrix Community space](https://community.aviatrix.com/tech-zone-14/aviatrix-cloud-sandbox-starter-spin-up-cloud-networks-in-minutes-203?tid=203&fid=14)

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
- Subscription to the [Aviatrix Secure Networking Platform Metered 2208-Universal 24x7 Support](https://aws.amazon.com/marketplace/pp/prodview-qzvzwigqw72ek) from the AWS Marketplace. You must subscribe and generate a license key.

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
