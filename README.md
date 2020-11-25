# Docker Preboot Execution Environment TFTP server
`tftp-hpa` from `alpine:latest` serving the contents of a PXE boot server.

Use `docker-compose up` to start the service.

DHCP server *is not included*.

## Default boot entries
- Memtest86+
- Clonezilla
- GParted

## Customizing

### [.env_pxeboot](.env_pxeboot)
Edit this file to change the title, password or the IP address of the pxe/tftp server that serves the contents of a live image.

### [pxeboot/gen-pxeboot-cfg.sh](pxeboot/gen-pxeboot-cfg.sh)

Edit this file if you want to change the boot entries.
