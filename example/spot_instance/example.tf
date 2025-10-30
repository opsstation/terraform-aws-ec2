provider "aws" {
  region = "eu-west-1"
}

locals {
  environment = "test-app"
  label_order = ["name", "environment"]
}

##======================================================================================
## A VPC is a virtual network that closely resembles a traditional network that you'd operate in your own data center.
##=====================================================================================
module "vpc" {
  source      = "git::https://github.com/opsstation/terraform-aws-vpc?ref=v1.0.0"
  name        = "app"
  environment = local.environment
  label_order = local.label_order
  cidr_block  = "172.16.0.0/16"
}


##=======================================================================
## A subnet is a range of IP addresses in your VPC.
##========================================================================
module "public_subnets" {
  source             = "git::https://github.com/opsstation/terraform-aws-subnet?ref=v1.0.0"
  name               = "public-subnet"
  environment        = local.environment
  label_order        = local.label_order
  availability_zones = ["eu-west-1b", "eu-west-1c"]
  vpc_id             = module.vpc.id
  cidr_block         = module.vpc.vpc_cidr_block
  type               = "public"
  igw_id             = module.vpc.igw_id
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
}


##=====================================================================
## Terraform module to create spot instance module on AWS.
##=====================================================================
module "spot-ec2" {
  source      = "./../../."
  name        = "ec2"
  environment = "test"

  ##======================================================================================
  ## Below A security group controls the traffic that is allowed to reach and leave the resources that it is associated with.
  ##======================================================================================
  vpc_id            = module.vpc.id
  ssh_allowed_ip    = ["0.0.0.0/0"]
  ssh_allowed_ports = [22]

  #Keypair
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDhO7EpkyvNOP/e8G25GR0n1GkhQrI7oLsDN5GSIVWA9vW2CjJHUKxz+pVraAdwxTe0cLp9vdJPiy+rlo4PO0H1hwYJV9bcw+j2TlG++e6Ct/ZSrY0y4WJk2VF/YoDDYlweDiy5+u9e90lSTRRLo4qwltxkGrlOxtvP8+es2lzA7pDbQjgineZqiG58aoWYY2p/G+ROfRMvVtXo7+2inVuQafh55R8uJbb0qECAG0JGNtszdXYxleivOkKMugSbKjpcwtaA5swy0w+6ndcsJqfOCNGi74wyzZy7wC4/A3RNlQnOhRM+9ji89RmT9vLwsa1cXvcNjSk3NfpL7OZWNZ2C+TjFjuTwlIW9NdUqlKrbrQu34eP2tRTodE4/BXpHDO3kwz/885fxqo7occP/YNmloDQ8XqN5npTpVKsB9vSoQz3SprGF8tdn7D4GOaYew1lloqZ8KNC+ITMguMgIo2fhbn7xjvMp2M/3/GhZVs19xu0rGxpxqiV9HQefiKbtyiTbYCPqFhQva/C8YK3P8MD4m3Nj3DuAvkOwQNIsXPWTlBKnB+SEgZgFgxD6G10sgL9uUgSglZ7bH6cpjJyYJoFj5BkLLYVuL6CthmzMjdn5C23gMzll8MVAHWs1gSld1nHY+k3XfQ7A78Vyu99MZKWpmqGzLTdhEQnGFCFtbg+NPQ== vinod.yadav"

  # Spot-instance
  spot_price                          = "0.3"
  spot_wait_for_fulfillment           = true
  spot_type                           = "persistent"
  spot_instance_interruption_behavior = "terminate"
  spot_instance_enabled               = true
  spot_instance_count                 = 1
  instance_type                       = "c4.xlarge"

  #Networking
  subnet_ids = tolist(module.public_subnets.public_subnet_id)

  #Root Volume
  root_block_device = [
    {
      volume_type           = "gp2"
      volume_size           = 15
      delete_on_termination = true
    }
  ]

  #EBS Volume
  ebs_volume_enabled = true
  ebs_volume_type    = "gp2"
  ebs_volume_size    = 30

  #Tags
  spot_instance_tags = { "snapshot" = true }

}
