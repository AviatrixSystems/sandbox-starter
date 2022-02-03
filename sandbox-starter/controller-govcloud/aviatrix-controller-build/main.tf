resource "aws_eip" "controller_eip" {
  count = var.num_controllers
  vpc   = true
  tags  = local.common_tags
}

resource "aws_eip_association" "eip_assoc" {
  count         = var.num_controllers
  instance_id   = aws_instance.aviatrixcontroller[count.index].id
  allocation_id = aws_eip.controller_eip[count.index].id
}

resource "aws_network_interface" "eni-controller" {
  count           = var.num_controllers
  subnet_id       = var.subnet
  security_groups = [aws_security_group.AviatrixSecurityGroup.id]
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}Aviatrix Controller interface : {count.index}"
  })
}

resource "aws_instance" "aviatrixcontroller" {
  count                   = var.num_controllers
  ami                     = local.ami_id
  instance_type           = var.instance_type
  key_name                = var.keypair
  iam_instance_profile    = var.ec2role
  disable_api_termination = var.termination_protection

  network_interface {
    network_interface_id = aws_network_interface.eni-controller[count.index].id
    device_index         = 0
  }

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}AviatrixController-${count.index}"
  })

  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}

# Copilot
resource "aws_instance" "aws_copilot" {
  ami = "ami-014a0430dcbd64db5"
  # instance_type          = var.instance_type
  instance_type          = "t3.2xlarge"
  subnet_id              = var.subnet
  key_name               = var.keypair
  vpc_security_group_ids = [aws_security_group.aws_copilot.id]

  ebs_block_device {
    device_name = "/dev/sda2"
    encrypted   = true
    volume_type = "gp2"
    volume_size = "25"
  }
  tags = {
    Name = "AviatrixCopilot"
  }
}

resource "aws_eip" "aws_copilot_eip" {
  instance = aws_instance.aws_copilot.id
  vpc      = true
  tags = {
    Name = "aws-copilot-eip"
  }
}

resource "aws_security_group" "aws_copilot" {
  name   = "aws-copilot-sg"
  vpc_id = var.vpc
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 31283
    to_port     = 31283
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "aws-copilot-sg"
  }
}
