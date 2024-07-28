######################################
#           _             _ _        #
#          | |           (_) |       #
#          | | __ ___   ___| | __    #
#      _   | |/ _` \ \ / / | |/ /    #
#     | |__| | (_| |\ V /| |   <     #
#      \____/ \__,_| \_/ |_|_|\_\    #
#                                    #
######################################

# Filename: floating_ip.tf
# Description: 
# Version: 1.1
# Author: Benjamin Schneider <ich@benjamin-schneider.com>
# Date: 2024-06-08
# Last Modified: 2024-06-12
# Changelog: 
# 1.1 - Mutli dns support
# 1.0 - Initial version 

###################
###    Split    ###
###################

resource "terraform_data" "floating_ips_split" {
  for_each = toset(local.floating_ip_dns)

  triggers_replace = {
    parts = split(".", each.value)
  }
}

###################
###    Domain   ###
###################

resource "terraform_data" "floating_ips_domain" {
  for_each = toset(local.floating_ip_dns)

  triggers_replace = {
    fqdn            = each.value
    tld             = try(element(terraform_data.floating_ips_split[each.key].triggers_replace.parts, length(terraform_data.floating_ips_split[each.key].triggers_replace.parts) - 1), null)
    domain          = try(element(terraform_data.floating_ips_split[each.key].triggers_replace.parts, length(terraform_data.floating_ips_split[each.key].triggers_replace.parts) - 2), null)
    subdomain       = try(element(terraform_data.floating_ips_split[each.key].triggers_replace.parts, length(terraform_data.floating_ips_split[each.key].triggers_replace.parts) - 3), null)
    domain_with_tld = try(join(".", [element(terraform_data.floating_ips_split[each.key].triggers_replace.parts, length(terraform_data.floating_ips_split[each.key].triggers_replace.parts) - 2), element(terraform_data.floating_ips_split[each.key].triggers_replace.parts, length(terraform_data.floating_ips_split[each.key].triggers_replace.parts) - 1)]), null)
  }
}


###################
### Floating IP ###
###################

resource "hcloud_floating_ip" "floating_ip" {
  for_each = var.floating_ips

  name = format("%s-%s",
    each.key,
    each.value.type,
  )

  type          = each.value.type
  description   = each.value.description
  home_location = each.value.location
}

###################
###    rDNS     ###
###################

resource "hcloud_rdns" "floating_ip_rdns" {
  for_each = var.floating_ips

  floating_ip_id = hcloud_floating_ip.floating_ip[each.key].id
  ip_address     = (each.value.type == "ipv4" ? hcloud_floating_ip.floating_ip[each.key].ip_address : "${hcloud_floating_ip.floating_ip[each.key].ip_address}1")
  dns_ptr        = each.value.dns[0]
}

###################
###     DNS     ###
###################

resource "cloudflare_record" "floating_ip_dns" {
  count = length(local.floating_ip_list) * length(local.floating_ip_dns)

  zone_id = var.cloudflare_zones[
    terraform_data.floating_ips_domain[
      local.floating_ip_dns[
        count.index % length(local.floating_ip_dns)
      ]
    ].triggers_replace.domain_with_tld
  ]
  name    = local.floating_ip_list[count.index % length(local.floating_ip_list)].dns[count.index % length(local.floating_ip_dns)]
  value   = (local.floating_ip_list[count.index % length(local.floating_ip_list)].type == "ipv4" ? local.hcloud_floating_ip[count.index % length(local.floating_ip_list)].ip_address : "${local.hcloud_floating_ip[count.index % length(local.floating_ip_list)].ip_address}1")
  type    = (local.floating_ip_list[count.index % length(local.floating_ip_list)].type == "ipv4" ? "A" : "AAAA")
  ttl     = (local.floating_ip_list[count.index % length(local.floating_ip_list)].proxy == true ? var.cloudflare_proxied_ttl : var.cloudflare_ttl)
  proxied = local.floating_ip_list[count.index % length(local.floating_ip_list)].proxy
  comment = "Managed by Terraform"
}
