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
# Version: 1.3
# Author: Benjamin Schneider <ich@benjamin-schneider.com>
# Date: 2024-04-25
# Last Modified: 2024-06-12
# Changelog: 
# 1.3 - Add locals for floating ip dns
# 1.2 - Removed floating_ips variable
# 1.1 - Added floating_ips variable
# 1.0 - Initial version 

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

  floating_ip_dns = distinct(flatten(tolist([
    for floating_ip in var.floating_ips : [for dns in floating_ip.dns : dns]
  ])))

  hcloud_floating_ip = flatten(tolist([
    for floating_ip in hcloud_floating_ip.floating_ip : floating_ip
  ]))

  floating_ip_list = [
    for floating_ip in var.floating_ips : {
      type        = floating_ip.type
      dns         = floating_ip.dns
      description = floating_ip.description
      location    = floating_ip.location
      proxy       = floating_ip.proxy
    }
  ]

  cloudflare_zone_list = [
    for zone in var.cloudflare_zones : zone
  ]
}
