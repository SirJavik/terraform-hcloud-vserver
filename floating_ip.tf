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
# Version: 1.5.0
# Author: Benjamin Schneider <ich@benjamin-schneider.com>
# Date: 2024-06-08
# Last Modified: 2024-08-03
# Changelog: 
# 1.5.0 - Add labels
# 1.4.3 - Use local.hcloud_floating_ips
# 1.4.2 - Use map for rdns
# 1.4.1 - Use floating ip maps  
# 1.4.0 - Split ip creation
# 1.3.3 - Fix wrong ip address
# 1.3.2 - Fix wrong variable
# 1.3.1 - Fix floating ip dns
# 1.2.1 - Fix wrong index
# 1.2.0 - Split ipv4 and ipv6
# 1.1.0 - Mutli dns support
# 1.0.0 - Initial version 

###################
###    Split    ###
###################

resource "terraform_data" "floating_ipv4s_split" {
  for_each = toset(local.floating_ipv4_dns)

  triggers_replace = {
    parts = split(".", each.value)
  }
}

resource "terraform_data" "floating_ipv6s_split" {
  for_each = toset(local.floating_ipv6_dns)

  triggers_replace = {
    parts = split(".", each.value)
  }
}

###################
###    Domain   ###
###################

resource "terraform_data" "floating_ipv4s_domain" {
  for_each = toset(local.floating_ipv4_dns)

  triggers_replace = {
    fqdn            = each.value
    tld             = try(element(terraform_data.floating_ipv4s_split[each.key].triggers_replace.parts, length(terraform_data.floating_ipv4s_split[each.key].triggers_replace.parts) - 1), null)
    domain          = try(element(terraform_data.floating_ipv4s_split[each.key].triggers_replace.parts, length(terraform_data.floating_ipv4s_split[each.key].triggers_replace.parts) - 2), null)
    subdomain       = try(element(terraform_data.floating_ipv4s_split[each.key].triggers_replace.parts, length(terraform_data.floating_ipv4s_split[each.key].triggers_replace.parts) - 3), null)
    domain_with_tld = try(join(".", [element(terraform_data.floating_ipv4s_split[each.key].triggers_replace.parts, length(terraform_data.floating_ipv4s_split[each.key].triggers_replace.parts) - 2), element(terraform_data.floating_ipv4s_split[each.key].triggers_replace.parts, length(terraform_data.floating_ipv4s_split[each.key].triggers_replace.parts) - 1)]), null)
  }
}

resource "terraform_data" "floating_ipv6s_domain" {
  for_each = toset(local.floating_ipv6_dns)

  triggers_replace = {
    fqdn            = each.value
    tld             = try(element(terraform_data.floating_ipv6s_split[each.key].triggers_replace.parts, length(terraform_data.floating_ipv6s_split[each.key].triggers_replace.parts) - 1), null)
    domain          = try(element(terraform_data.floating_ipv6s_split[each.key].triggers_replace.parts, length(terraform_data.floating_ipv6s_split[each.key].triggers_replace.parts) - 2), null)
    subdomain       = try(element(terraform_data.floating_ipv6s_split[each.key].triggers_replace.parts, length(terraform_data.floating_ipv6s_split[each.key].triggers_replace.parts) - 3), null)
    domain_with_tld = try(join(".", [element(terraform_data.floating_ipv6s_split[each.key].triggers_replace.parts, length(terraform_data.floating_ipv6s_split[each.key].triggers_replace.parts) - 2), element(terraform_data.floating_ipv6s_split[each.key].triggers_replace.parts, length(terraform_data.floating_ipv6s_split[each.key].triggers_replace.parts) - 1)]), null)
  }
}


###################
### Floating IP ###
###################

resource "hcloud_floating_ip" "floating_ipv4" {
  for_each = local.floating_ipv4_map

  name = format("%s-%s",
    each.key,
    each.value.type,
  )

  type          = each.value.type
  description   = each.value.description
  home_location = each.value.location

  labels = {
    environment = var.environment,
    domain      = each.value.dns[0]
    managed_by  = "terraform",
  }
}

resource "hcloud_floating_ip" "floating_ipv6" {
  for_each = local.floating_ipv6_map

  name = format("%s-%s",
    each.key,
    each.value.type,
  )

  type          = each.value.type
  description   = each.value.description
  home_location = each.value.location

  labels = {
    environment = var.environment,
    domain      = each.value.dns[0]
    managed_by  = "terraform",
  }
}

###################
###    rDNS     ###
###################

resource "hcloud_rdns" "floating_ipv4_rdns" {
  for_each = local.floating_ipv4_map

  floating_ip_id = hcloud_floating_ip.floating_ipv4[each.key].id
  ip_address     = (each.value.type == "ipv4" ? hcloud_floating_ip.floating_ipv4[each.key].ip_address : "${hcloud_floating_ip.floating_ipv4[each.key].ip_address}1")
  dns_ptr        = each.value.dns[0]
}

resource "hcloud_rdns" "floating_ipv6_rdns" {
  for_each = local.floating_ipv6_map

  floating_ip_id = hcloud_floating_ip.floating_ipv6[each.key].id
  ip_address     = (each.value.type == "ipv4" ? hcloud_floating_ip.floating_ipv6[each.key].ip_address : "${hcloud_floating_ip.floating_ipv6[each.key].ip_address}1")
  dns_ptr        = each.value.dns[0]
}

###################
###     DNS     ###
###################

resource "cloudflare_record" "floating_ipv4_dns" {
  count = length(local.floating_ipv4_list) * length(local.floating_ipv4_dns)

  zone_id = var.cloudflare_zones[
    terraform_data.floating_ipv4s_domain[
      local.floating_ipv4_dns[
        count.index % length(local.floating_ipv4_dns)
      ]
    ].triggers_replace.domain_with_tld
  ]
  name    = local.floating_ipv4_list[count.index % length(local.floating_ipv4_list)].dns[count.index % length(local.floating_ipv4_dns)]
  value   = local.hcloud_floating_ipv4[count.index % length(local.floating_ipv4_list)].ip_address
  type    = "A"
  ttl     = (local.floating_ipv4_list[count.index % length(local.floating_ipv4_list)].proxy == true ? var.cloudflare_proxied_ttl : var.cloudflare_ttl)
  proxied = local.floating_ipv4_list[count.index % length(local.floating_ipv4_list)].proxy
  comment = "Managed by Terraform"
}

resource "cloudflare_record" "floating_ipv6_dns" {
  count = length(local.floating_ipv6_list) * length(local.floating_ipv6_dns)

  zone_id = var.cloudflare_zones[
    terraform_data.floating_ipv6s_domain[
      local.floating_ipv6_dns[
        count.index % length(local.floating_ipv6_dns)
      ]
    ].triggers_replace.domain_with_tld
  ]
  name    = local.floating_ipv6_list[count.index % length(local.floating_ipv6_list)].dns[count.index % length(local.floating_ipv6_dns)]
  value   = "${local.hcloud_floating_ipv6[count.index % length(local.floating_ipv6_list)].ip_address}1"
  type    = "AAAA"
  ttl     = (local.floating_ipv6_list[count.index % length(local.floating_ipv6_list)].proxy == true ? var.cloudflare_proxied_ttl : var.cloudflare_ttl)
  proxied = local.floating_ipv6_list[count.index % length(local.floating_ipv6_list)].proxy
  comment = "Managed by Terraform"
}
