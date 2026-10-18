#!/bin/bash
set -euo pipefail
mkdir -p /etc/nfs.conf.d /etc/exports.d /etc/systemd/system/rpcbind.socket.d
cat > /etc/nfs.conf.d/ak2-kzirx.conf <<'EOF'
[nfsd]
host=127.0.0.1
vers4=n
[mountd]
port=20048
EOF
cat > /etc/systemd/system/rpcbind.socket.d/ak2-local.conf <<'EOF'
[Socket]
ListenStream=
ListenDatagram=
ListenStream=/run/rpcbind.sock
ListenStream=127.0.0.1:111
ListenDatagram=127.0.0.1:111
EOF
printf '%s\n' '/srv/ak2/kzirx/lab3/rootfs 127.0.0.1(rw,sync,no_root_squash,no_subtree_check,insecure)' > /etc/exports.d/ak2-kzirx.exports
systemctl stop nfs-server rpcbind.service rpcbind.socket
systemctl daemon-reload
systemctl start rpcbind.socket rpcbind.service nfs-server
exportfs -rav
ss -lntup | grep -E ':111 |:2049 |:20048 ' || true
exportfs -v
