######################################
#           _             _ _        #
#          | |           (_) |       #
#          | | __ ___   ___| | __    #
#      _   | |/ _` \ \ / / | |/ /    #
#     | |__| | (_| |\ V /| |   <     #
#      \____/ \__,_| \_/ |_|_|\_\    #
#                                    #
######################################

# Filename: rdns.tf
# Description: 
# Version: 1.0
# Author: Benjamin Schneider <ich@benjamin-schneider.com>
# Date: 2024-04-25
# Last Modified: 2024-04-26
# Changelog: 
# 1.0 - Initial version 

resource "hcloud_rdns" "rdns_ipv4" {
  for_each   = local.server
  server_id  = each.value.id
  ip_address = each.value.ipv4_address
  dns_ptr    = each.value.name
}

resource "hcloud_rdns" "rdns_ipv6" {
  for_each   = local.server
  server_id  = each.value.id
  ip_address = each.value.ipv6_address
  dns_ptr    = each.value.name
}
