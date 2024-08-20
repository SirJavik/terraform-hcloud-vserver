######################################
#           _             _ _        #
#          | |           (_) |       #
#          | | __ ___   ___| | __    #
#      _   | |/ _` \ \ / / | |/ /    #
#     | |__| | (_| |\ V /| |   <     #
#      \____/ \__,_| \_/ |_|_|\_\    #
#                                    #
######################################

# Filename: additional_names.tf
# Description: 
# Version: 1.1.2
# Author: Benjamin Schneider <ich@benjamin-schneider.com>
# Date: 2024-07-20
# Last Modified: 2024-08-20
# Changelog: 
# 1.1.2 - Fix additional_names_dns_cname
# 1.1.1 - Fix ttl
# 1.1.0 - Add proxy option for additional names
# 1.0.0 - Initial version 

###################
###    Split    ###
###################

resource "terraform_data" "additional_names_split" {
  for_each = toset(local.additional_names_list)
  triggers_replace = {
    parts = split(".", each.key)
  }
}

###################
###    Domain   ###
###################

resource "terraform_data" "additional_names_parts" {
  for_each = toset(local.additional_names_list)

  triggers_replace = {
    fulldomain      = each.key
    tld             = try(element(terraform_data.additional_names_split[each.key].triggers_replace.parts, length(terraform_data.additional_names_split[each.key].triggers_replace.parts) - 1), null)
    domain          = try(element(terraform_data.additional_names_split[each.key].triggers_replace.parts, length(terraform_data.additional_names_split[each.key].triggers_replace.parts) - 2), null)
    subdomain       = try(element(terraform_data.additional_names_split[each.key].triggers_replace.parts, length(terraform_data.additional_names_split[each.key].triggers_replace.parts) - 3), null)
    domain_with_tld = try(join(".", [element(terraform_data.additional_names_split[each.key].triggers_replace.parts, length(terraform_data.additional_names_split[each.key].triggers_replace.parts) - 2), element(terraform_data.additional_names_split[each.key].triggers_replace.parts, length(terraform_data.additional_names_split[each.key].triggers_replace.parts) - 1)]), null)
  }
}

###################
###     DNS     ###
###################

resource "cloudflare_record" "additional_names_dns_cname" {
  count = length(var.additional_names) * var.service_count

  zone_id = var.cloudflare_zones[
    terraform_data.additional_names_parts[
      local.additional_names_list[
        count.index % length(local.additional_names_list)
      ]
    ].triggers_replace.domain_with_tld
  ]
  name    = local.additional_names_list[count.index % length(local.additional_names_list)]
  value   = hcloud_server.vserver[count.index % var.service_count].name
  type    = "CNAME"
  ttl     = (var.additional_names[local.additional_names_list[count.index % length(local.additional_names_list)]].proxy ? var.cloudflare_proxied_ttl : var.cloudflare_ttl)
  proxied = var.additional_names[local.additional_names_list[count.index % length(local.additional_names_list)]].proxy
  comment = "Managed by Terraform"
}
