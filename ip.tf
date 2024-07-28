######################################
#           _             _ _        #
#          | |           (_) |       #
#          | | __ ___   ___| | __    #
#      _   | |/ _` \ \ / / | |/ /    #
#     | |__| | (_| |\ V /| |   <     #
#      \____/ \__,_| \_/ |_|_|\_\    #
#                                    #
######################################

# Filename: ip.tf
# Description: 
# Version: 1.0
# Author: Benjamin Schneider <ich@benjamin-schneider.com>
# Date: 2024-04-26
# Last Modified: 2024-04-26
# Changelog: 
# 1.0 - Initial version 

resource "hcloud_primary_ip" "ipv4" {
  count = var.service_count

  name = (var.environment == "live" ? format("%s-%s.%s-%s",
    "${var.name_prefix}${count.index + 1}",
    (count.index % 2 == 0 ? var.locations[0] : var.locations[1]),
    var.domain,
    "ipv4"
    ) : format("%s-%s-%s.%s-%s",
    var.environment,
    "${var.name_prefix}${count.index + 1}",
    (count.index % 2 == 0 ? var.locations[0] : var.locations[1]),
    var.domain,
    "ipv4"
  ))
  datacenter    = (count.index % 2 == 0 ? var.datacenters[0] : var.datacenters[1])
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = false
}

resource "hcloud_primary_ip" "ipv6" {
  count = var.service_count

  name = (var.environment == "live" ? format("%s-%s.%s-%s",
    "${var.name_prefix}${count.index + 1}",
    (count.index % 2 == 0 ? var.locations[0] : var.locations[1]),
    var.domain,
    "ipv6"
    ) : format("%s-%s-%s.%s-%s",
    var.environment,
    "${var.name_prefix}${count.index + 1}",
    (count.index % 2 == 0 ? var.locations[0] : var.locations[1]),
    var.domain,
    "ipv6"
  ))
  datacenter    = (count.index % 2 == 0 ? var.datacenters[0] : var.datacenters[1])
  type          = "ipv6"
  assignee_type = "server"
  auto_delete   = false
}
