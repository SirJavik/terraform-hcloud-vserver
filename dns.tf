######################################
#           _             _ _        #
#          | |           (_) |       #
#          | | __ ___   ___| | __    #
#      _   | |/ _` \ \ / / | |/ /    #
#     | |__| | (_| |\ V /| |   <     #
#      \____/ \__,_| \_/ |_|_|\_\    #
#                                    #
######################################

# Filename: dns.tf
# Description: 
# Version: 1.0
# Author: Benjamin Schneider <ich@benjamin-schneider.com>
# Date: 2024-06-12
# Last Modified: 2024-06-12
# Changelog: 
# 1.0 - Initial version

resource "terraform_data" "server_name" {
  for_each = local.servers

  triggers_replace = {
    parts = split(".", each.value.name)
  }
}


resource "terraform_data" "domain_data" {
  for_each = local.servers

  triggers_replace = {
    fqdn            = each.value.name
    tld             = try(element(terraform_data.server_name[each.key].triggers_replace.parts, length(terraform_data.server_name[each.key].triggers_replace.parts) - 1), null)
    domain          = try(element(terraform_data.server_name[each.key].triggers_replace.parts, length(terraform_data.server_name[each.key].triggers_replace.parts) - 2), null)
    subdomain       = try(element(terraform_data.server_name[each.key].triggers_replace.parts, length(terraform_data.server_name[each.key].triggers_replace.parts) - 3), null)
    host            = try(element(terraform_data.server_name[each.key].triggers_replace.parts, 0), null)
    domain_with_tld = try(join(".", [element(terraform_data.server_name[each.key].triggers_replace.parts, length(terraform_data.server_name[each.key].triggers_replace.parts) - 2), element(terraform_data.server_name[each.key].triggers_replace.parts, length(terraform_data.server_name[each.key].triggers_replace.parts) - 1)]), null)
  }
}

resource "cloudflare_record" "ipv4_dns" {
  for_each = local.servers

  zone_id = var.cloudflare_zones[terraform_data.domain_data[each.key].triggers_replace.domain_with_tld]
  name    = each.value.name
  value   = try(lookup(each.value, "ipv4"), lookup(each.value, "ipv4_address"))
  type    = "A"
  ttl     = var.cloudflare_ttl
  comment = "Managed by Terraform"
}

resource "cloudflare_record" "ipv6_dns" {
  for_each = local.servers

  zone_id = var.cloudflare_zones[terraform_data.domain_data[each.key].triggers_replace.domain_with_tld]
  name    = each.value.name
  value   = try(lookup(each.value, "ipv6"), lookup(each.value, "ipv6_address"))
  type    = "AAAA"
  ttl     = var.cloudflare_ttl
  comment = "Managed by Terraform"
}

resource "cloudflare_record" "txt_dns" {
  for_each = local.servers

  zone_id = var.cloudflare_zones[terraform_data.domain_data[each.key].triggers_replace.domain_with_tld]
  name    = each.value.name
  value   = each.value.name
  type    = "TXT"
  ttl     = var.cloudflare_ttl
  comment = "Managed by Terraform"
}
