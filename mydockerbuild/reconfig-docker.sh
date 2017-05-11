service docker stop
rm -rf /var/lib/docker
/etc/init.d/docker restart
dd if=/dev/zero of=/var/lib/docker/devicemapper/devicemapper/data bs=1G count=0 seek=20
