######################################
#           _             _ _        #
#          | |           (_) |       #
#          | | __ ___   ___| | __    #
#      _   | |/ _` \ \ / / | |/ /    #
#     | |__| | (_| |\ V /| |   <     #
#      \____/ \__,_| \_/ |_|_|\_\    #
#                                    #
######################################

# Filename: main.tf
# Description: 
# Version: 1.0.1
# Author: Benjamin Schneider <ich@benjamin-schneider.com>
# Date: 2024-04-25
# Last Modified: 2024-07-28
# Changelog: 
# 1.0.1 - Add keep_disk variable, cloud_init variable, add_index variable
# 1.0.0 - Initial version 

resource "hcloud_server" "vserver" {
  count = var.service_count

  name = (var.environment == "live" ? format("%s%s-%s.%s",
    "${var.name_prefix}",
    (var.add_index == true ? "${count.index + 1}" : ""),
    (count.index % 2 == 0 ? var.locations[0] : var.locations[1]),
    var.domain,

    ) : format("%s-%s%s-%s.%s",
    var.environment,
    "${var.name_prefix}",
    (var.add_index == true ? "${count.index + 1}" : ""),
    (count.index % 2 == 0 ? var.locations[0] : var.locations[1]),
    var.domain
  ))

  keep_disk = var.keep_disk

  image       = var.image
  server_type = var.type
  location    = (count.index % 2 == 0 ? var.locations[0] : var.locations[1])
  ssh_keys    = var.ssh_key_ids
  user_data   = file("${path.module}/cloud-init.yml")

  public_net {
    ipv4 = hcloud_primary_ip.ipv4[count.index].id
    ipv6 = hcloud_primary_ip.ipv6[count.index].id
  }

  network {
    network_id = var.network_id
    ip         = "${substr(var.subnet, 0, length(var.subnet) - 5)}.${(count.index + 1) * 10}"
  }

  firewall_ids = [
    hcloud_firewall.firewall.id
  ]

  labels = local.labels

  placement_group_id = hcloud_placement_group.placement_group.id

  depends_on = [
    hcloud_network_subnet.vserver_subnet
  ]
}