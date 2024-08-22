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
# Version: 1.2
# Author: Benjamin Schneider <ich@benjamin-schneider.com>
# Date: 2024-04-25
# Last Modified: 2024-08-22
# Changelog: 
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
