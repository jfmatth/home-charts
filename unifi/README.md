# Unifi router 

## Hairpin for various ports
- 80/443
- 25565 (Minecraft)

### NAT Changed
Source NAT
| Order | Description | Source | Destination | Translation |
| ----- | ----------- | ------ | ----------- | ----------- |
| 2     | Hairpin-DMS | 192.168.100.0/24 | 192.168.100.140, Port 80,443, 25565 | masquarade to eth2 |

Destination NAT
| Order | Description | Source | Destination | Translation |
| ----- | ----------- | ------ | ----------- | ----------- |
| 2     | Hairpin-DMS | 192.168.100.0/24 | 192.168.100.140, Port 80,443, 25565 | masquarade to eth2 |





# Ubiquity Unifi controller for AP's in home

Run's the controller on your local machine.

- Download and Run Unifi controller for Windows 9.4.19
   https://dl.ui.com/unifi/9.4.19/UniFi-installer.exe

- Manage with Browser - Might need to link to the Unifi account, that's OK.
- Restore from backup in ```Documents\Home\Network\```
- After restore, refresh and login
   jfmatth
   P0



