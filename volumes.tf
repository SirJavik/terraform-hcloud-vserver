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
# Version: 1.1
# Author: Benjamin Schneider <ich@benjamin-schneider.com>
# Date: 2024-04-26
# Last Modified: 2024-08-23
# Changelog: 
# 1.1 - Add random_integer for volume suffix
# 1.0 - Initial version 

resource "random_integer" "vol_suffix" {
  count = length(local.volumes_list) * length(local.server_list)
  min   = 1000
  max   = 9999
}

resource "hcloud_volume" "volume" {
  count = length(local.volumes_list) * length(local.server_list)

  name = format("%s-%s-%d",
    local.server_list[count.index % length(local.server_list)].name,
    local.volumes_list[count.index % length(local.volumes_list)].name,
    random_integer.vol_suffix[count.index].result
  )

  size      = local.volumes_list[count.index % length(local.volumes_list)].size
  server_id = local.server_list[count.index % length(local.server_list)].id
  labels    = local.labels
}