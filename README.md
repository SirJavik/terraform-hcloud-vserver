# Terraform Module: vserver

This Terraform module creates a virtual server (vserver) in a cloud environment.

## Features

- Easy deployment of virtual servers
- Customizable server configurations
- Scalable infrastructure
- Automated provisioning

## Usage

```hcl
module "vserver" {
    source = "git::https://github.com/your-organization/vserver-module.git"

    name        = "my-vserver"
    image       = "ubuntu-20.04"
    size        = "small"
    region      = "us-west-1"
    subnet_id   = "subnet-12345678"
    security_group_ids = ["sg-12345678"]
}
```

## Inputs

| Name                | Description                       | Type   | Default | Required |
|---------------------|-----------------------------------|--------|---------|----------|
| name                | Name of the virtual server         | string | n/a     | yes      |
| image               | Server image to use                | string | n/a     | yes      |
| size                | Size of the virtual server         | string | n/a     | yes      |
| region              | Region where the server is deployed| string | n/a     | yes      |
| subnet_id           | ID of the subnet to deploy in      | string | n/a     | yes      |
| security_group_ids  | List of security group IDs         | list   | n/a     | yes      |

## Outputs

| Name                | Description                       |
|---------------------|-----------------------------------|
| server_id           | ID of the created virtual server   |
| server_ip           | IP address of the virtual server   |

## License

This module is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
