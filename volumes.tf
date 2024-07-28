######################################
#           _             _ _        #
#          | |           (_) |       #
#          | | __ ___   ___| | __    #
#      _   | |/ _` \ \ / / | |/ /    #
#     | |__| | (_| |\ V /| |   <     #
#      \____/ \__,_| \_/ |_|_|\_\    #
#                                    #
######################################

# Filename: volumes.tf
# Description: 
# Version: 1.0
# Author: Benjamin Schneider <ich@benjamin-schneider.com>
# Date: 2024-04-26
# Last Modified: 2024-04-26
# Changelog: 
# 1.0 - Initial version 

resource "hcloud_volume" "volume" {
  count = length(var.volumes) * length(local.server)

  name = format("%s-%s",
    local.server_list[count.index % length(local.server_list)].name,
    local.volumes_list[count.index % length(local.volumes_list)].name
  )

  size      = local.volumes_list[count.index % length(local.volumes_list)].size
  server_id = local.server_list[count.index % length(local.server_list)].id
  labels    = local.labels
}