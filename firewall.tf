######################################
#           _             _ _        #
#          | |           (_) |       #
#          | | __ ___   ___| | __    #
#      _   | |/ _` \ \ / / | |/ /    #
#     | |__| | (_| |\ V /| |   <     #
#      \____/ \__,_| \_/ |_|_|\_\    #
#                                    #
######################################

# Filename: firewall.tf
# Description: 
# Version: 1.0.0
# Author: Benjamin Schneider <ich@benjamin-schneider.com>
# Date: 2024-07-20
# Last Modified: 2024-07-20
# Changelog: 
# 1.0.0 - Initial version

resource "hcloud_firewall" "firewall" {
  name   = "${var.name_prefix}-firewall"
  labels = local.labels

  dynamic "rule" {
    for_each = var.firewall_rules
    content {
      direction   = rule.value.direction
      protocol    = rule.value.protocol
      port        = rule.value.port
      source_ips  = rule.value.source_ips
      description = rule.value.description
    }

  }
}
