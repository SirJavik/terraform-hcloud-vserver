######################################
#           _             _ _        #
#          | |           (_) |       #
#          | | __ ___   ___| | __    #
#      _   | |/ _` \ \ / / | |/ /    #
#     | |__| | (_| |\ V /| |   <     #
#      \____/ \__,_| \_/ |_|_|\_\    #
#                                    #
######################################

# Filename: locals.tf
# Description: 
# Version: 1.8.0
# Author: Benjamin Schneider <ich@benjamin-schneider.com>
# Date: 2024-04-25
# Last Modified: 2024-08-20
# Changelog: 
# 1.8.0 - Add local additional_names
# 1.7.1 - Fix wrong map
# 1.7.0 - Add map for floating ips
# 1.6.0 - Remove local.hcloud_floating_ips
# 1.5.1 - Add floating_ipv4_dns and floating_ipv6_dns
# 1.4.1 - Fix floating ip dns
# 1.4.0 - Add floating_ipv4_list and floating_ipv6_list
# 1.3.0 - Add locals for floating ip dns
# 1.2.0 - Removed floating_ips variable
# 1.1.0 - Added floating_ips variable
# 1.0.0 - Initial version 

locals {
  server = {
    for server in hcloud_server.vserver : server.name => server
  }

  volumes_list = [
    for key, volume in var.volumes : {
      name = key,
      size = volume.size
    }
  ]

  server_domains = toset(distinct([
    for domain in terraform_data.domain_data : domain.triggers_replace.domain_with_tld
  ]))

  server_list = [
    for server in local.server : server
  ]

  servers = {
    for server in hcloud_server.vserver : server.name => server
  }

  labels = merge({ environment = var.environment }, var.labels)
  module = basename(abspath(path.module))

  floating_ipv4_dns = distinct(flatten(tolist([
    for floating_ip in var.floating_ips : [for dns in floating_ip.dns : dns] if lower(floating_ip.type) == "ipv4"
  ])))

  floating_ipv6_dns = distinct(flatten(tolist([
    for floating_ip in var.floating_ips : [for dns in floating_ip.dns : dns] if lower(floating_ip.type) == "ipv6"
  ])))

  floating_ipv4_map = {
    for key, value in var.floating_ips : key => value if lower(value.type) == "ipv4"
  }

  floating_ipv6_map = {
    for key, value in var.floating_ips : key => value if lower(value.type) == "ipv6"
  }

  hcloud_floating_ipv4 = flatten(tolist([
    for floating_ip in hcloud_floating_ip.floating_ipv4 : floating_ip
  ]))

  hcloud_floating_ipv6 = flatten(tolist([
    for floating_ip in hcloud_floating_ip.floating_ipv6 : floating_ip
  ]))

  additional_names_dns = distinct(flatten(tolist([
    for additional_name in var.additional_names : [for dns in additional_name.dns : dns]
  ])))

  additional_names_list = [
    for additional_name in var.additional_names : {
      proxy = try(additional_name.proxy, false)
    }
  ]

  floating_ipv4_list = [
    for floating_ip in var.floating_ips : {
      type        = lower(floating_ip.type)
      dns         = floating_ip.dns
      description = try(floating_ip.description, "")
      location    = lower(floating_ip.location)
      proxy       = try(floating_ip.proxy, false)
    } if lower(floating_ip.type) == "ipv4"
  ]

  floating_ipv6_list = [
    for floating_ip in var.floating_ips : {
      type        = lower(floating_ip.type)
      dns         = floating_ip.dns
      description = try(floating_ip.description, "")
      location    = lower(floating_ip.location)
      proxy       = try(floating_ip.proxy, false)
    } if lower(floating_ip.type) == "ipv6"
  ]

  cloudflare_zone_list = [
    for zone in var.cloudflare_zones : zone
  ]
}
