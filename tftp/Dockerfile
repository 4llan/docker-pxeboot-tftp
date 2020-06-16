FROM alpine:latest
RUN apk add --no-cache tftp-hpa
EXPOSE 69/udp
ENTRYPOINT ["in.tftpd"]
CMD ["--foreground", "--secure", "/var/tftpboot"]
