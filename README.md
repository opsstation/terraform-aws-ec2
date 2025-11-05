# # 🏗️ Terraform-AWS-EC2

[![OpsStation](https://img.shields.io/badge/Made%20by-OpsStation-blue?style=flat-square&logo=terraform)](https://www.opsstation.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-1.13%2B-purple.svg?logo=terraform)](#)
[![CI](https://github.com/OpsStation/terraform-aws-ec2/actions/workflows/ci.yml/badge.svg)](https://github.com/OpsStation/terraform-aws-ec2/actions/workflows/ci.yml)

> 🌩️ **A production-grade, reusable AWS Ec2 module by [OpsStation](https://www.opsstation.com)**
> Designed for reliability, performance, and security — following AWS networking best practices.
---

## 🏢 About OpsStation

**OpsStation** delivers **Cloud & DevOps excellence** for modern teams:
- 🚀 **Infrastructure Automation** with Terraform, Ansible & Kubernetes
- 💰 **Cost Optimization** via scaling & right-sizing
- 🛡️ **Security & Compliance** baked into CI/CD pipelines
- ⚙️ **Fully Managed Operations** across AWS, Azure, and GCP

> 💡 Need enterprise-grade DevOps automation?
> 👉 Visit [**www.opsstation.com**](https://www.opsstation.com) or email **hello@opsstation.com**

---

## 🌟 Features

- ✅ Creates and manages **AWS EC2 instances** with customizable configurations
- ✅ Supports multiple **instance types** (e.g., t2.micro, t3.medium, m5.large)
- ✅ Optional **EBS volume attachments** for persistent storage
- ✅ Configurable **security groups**, **key pairs**, and **network interfaces**
- ✅ Seamless integration with other **AWS services** (e.g., VPC, S3, IAM, CloudWatch)
- ✅ Supports **auto-start**, **stop**, and **termination protection** options
- ✅ Compatible with **CloudWatch and CloudTrail** for monitoring and logging
- ✅ Tags and naming convention managed through the **Labels module**
- ✅ Seamless integration with other **OpsStation Terraform modules**

---
## ⚙️ Usage Example

# Example: default

```hcl
# Create EC2 instances
module "ec2" {
  source               = "git::https://github.com/opsstation/terraform-aws-ec2.git?ref=v1.0.0"
  name                 = "ec2"
  environment          = local.environment
  vpc_id               = module.vpc.vpc_id
  ssh_allowed_ip       = ["0.0.0.0/0"]
  ssh_allowed_ports    = [22]
  instance_count       = 2
  ami                  = "ami-01dd271720c1ba44f"
  instance_type        = "t2.micro"
  public_key           = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDhO7EpkyvNOP/e8G25GR0n1GkhQrIxxxxxxxxxxxxxxxxxxxxxxxxxxxxGzLTdhEQnGFCFtbg+NPQ== opsstation@opsstation"
  subnet_ids           = tolist(module.public_subnets.public_subnet_id)
  iam_instance_profile = module.iam-role.name

  root_block_device = [
    {
      volume_type           = "gp2"
      volume_size           = 15
      delete_on_termination = true
    }
  ]

  ebs_volume_enabled = true
  ebs_volume_type    = "gp2"
  ebs_volume_size    = 30

  instance_tags = { "snapshot" = true }

  #Mount EBS With User Data
  user_data = file("user-data.sh")
}
```

This example demonstrates how to create various AWS resources using the provided modules. Adjust the input values to suit your specific requirements.

# Example: spot_instance

```hcl
module "spot-ec2" {
  source      = "git::https://github.com/opsstation/terraform-aws-ec2.git?ref=v1.0.0"
  name        = "ec2"
  environment = "test"

  ##======================================================================================
  ## Below A security group controls the traffic that is allowed to reach and leave the resources that it is associated with.
  ##======================================================================================
  vpc_id            = module.vpc.vpc_id
  ssh_allowed_ip    = ["0.0.0.0/0"]
  ssh_allowed_ports = [22]

  #Keypair
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDhO7EpkyvNOP/e8G25GR0n1GkhQrIxxxxxxxxxxxxxxxxxxxxxxxxxxxxGzLTdhEQnGFCFtbg+NPQ== opsstation@opsstation"

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
```

### 🔐 Outputs (AWS EC2 Module)

| Name             | Description                                                                 |
|------------------|------------------------------------------------------------------------------|
| `id`             | The unique identifier (ID) of the created **EC2 instance**.                  |
| `arn`            | The ARN (Amazon Resource Name) of the created **EC2 instance**.              |
| `instance_state` | The current **state** of the EC2 instance (e.g., running, stopped).          |
| `private_ip`     | The **private IP address** assigned to the EC2 instance.                     |
| `public_ip`      | The **public IP address** assigned to the EC2 instance (if applicable).      |
| `subnet_id`      | The ID of the **subnet** where the instance is launched.                     |
| `vpc_security_group_ids` | The list of associated **security group IDs**.                        |
| `availability_zone` | The **Availability Zone** where the instance is running.                  |
| `key_name`       | The **SSH key pair name** associated with the EC2 instance.                  |
| `tags`           | A mapping of **tags** assigned to the EC2 resources.                         |

### ☁️ Tag Normalization Rules (AWS)

| Cloud | Case      | Allowed Characters | Example                            |
|--------|-----------|------------------|------------------------------------|
| **AWS** | TitleCase | Any              | `Name`, `Environment`, `CostCenter` |

---

### 💙 Maintained by [OpsStation](https://www.opsstation.com)
> OpsStation — Simplifying Cloud, Securing Scale.
