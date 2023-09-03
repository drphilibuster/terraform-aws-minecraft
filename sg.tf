// Security group for our instance - allows SSH and minecraft 
module "ec2_security_group" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-security-group.git"

  name        = "${var.name}-ec2"
  description = "Allow SSH and TCP ${var.mc_port}"
  vpc_id      = local.vpc_id

  ingress_cidr_blocks = var.allowed_cidrs
  ingress_rules       = ["ssh-tcp"]
  ingress_with_cidr_blocks = local.dynamic_ingress_rules
  egress_rules = ["all-all"]

  tags = module.label.tags
}
