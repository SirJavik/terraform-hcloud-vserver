######################################
#           _             _ _        #
#          | |           (_) |       #
#          | | __ ___   ___| | __    #
#      _   | |/ _` \ \ / / | |/ /    #
#     | |__| | (_| |\ V /| |   <     #
#      \____/ \__,_| \_/ |_|_|\_\    #
#                                    #
######################################

# Filename: outputs.tf
# Description: 
# Version: 1.3
# Author: Benjamin Schneider <ich@benjamin-schneider.com>
# Date: 2024-04-25
# Last Modified: 2024-08-23
# Changelog: 
# 1.3 - Add server_list and volumes_list output
# 1.2 - Reenable volumes output
# 1.1 - Disable volumes output
# 1.0 - Initial version 

output "server" {
  value = local.server
}

output "volumes" {
  value = {
  for volume in hcloud_volume.volume : volume.name => volume }
}

output "volumes_list" {
  value = local.volumes_list
}

output "server_list" {
  value = local.server_list
}