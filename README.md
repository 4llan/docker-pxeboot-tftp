# Docker Preboot Execution Environment TFTP server
`tftp-hpa` from `alpine:3.14` serving the contents of a PXELINUX boot server.

Use `docker-compose up` to start the service.

DHCP server *is not included*.

## Default boot entries
- Memtest86+
- Clonezilla
- GParted

## Customizing

### .env_pxeboot
Create a .env_pxeboot file to set some variables:
- PXE_TITLE
    - Menu title
- PXE_IP_ADDR
    - Set the IP address of pxe/tftp server. Required to load live images (filesystem.squashfs)
- PXE_PASSWD
    - Set the master password of pxe menu. Better use a hash, instead of plaintext

See [.env_pxeboot.sample](.env_pxeboot.sample).

### [pxeboot/gen-pxeboot-cfg.sh](pxeboot/gen-pxeboot-cfg.sh)

Edit this file if you want to change the boot entries.
