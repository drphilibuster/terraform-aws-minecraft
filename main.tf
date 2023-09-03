// This module creates a single EC2 instance for running a Minecraft server

// Keep labels, tags consistent

module "label" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git"

  namespace   = var.namespace
  stage       = var.environment
  name        = var.name
  delimiter   = "-"
  label_order = ["environment", "stage", "name", "attributes"]
  tags        = merge(var.tags, local.tf_tags)
}

// Create EC2 ssh key pair
resource "tls_private_key" "ec2_ssh" {
  count = length(var.key_name) > 0 ? 0 : 1

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_ssh" {
  count = length(var.key_name) > 0 ? 0 : 1

  key_name   = "${var.name}-ec2-ssh-key"
  public_key = tls_private_key.ec2_ssh[0].public_key_openssh
}

// EC2 instance for the server - tune instance_type to fit your performance and budget requirements
module "ec2_minecraft" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git"
  name   = "${var.name}-public"

  # instance
  key_name             = local._ssh_key_name
  ami                  = var.ami != "" ? var.ami : data.aws_ami.ubuntu.image_id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.mc.id
  user_data            = data.template_file.user_data.rendered

  # network
  subnet_id                   = local.subnet_id
  vpc_security_group_ids      = [module.ec2_security_group.security_group_id]
  associate_public_ip_address = var.associate_public_ip_address

  tags = module.label.tags
}
