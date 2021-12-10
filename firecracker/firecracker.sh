#!/usr/bin/env bash
set -eo pipefail

# install firecracker binary
# run firecracker in separate terminal, can run as user
# rm /tmp/firecracker.socket && firecracker --api-sock /tmp/firecracker.socket

arch=`uname -m`
dest_kernel="hello-vmlinux.bin"
dest_rootfs="hello-rootfs.ext4"
image_bucket_url="https://s3.amazonaws.com/spec.ccfc.min/img/quickstart_guide/$arch"
kernel="${image_bucket_url}/kernels/vmlinux.bin"
rootfs="${image_bucket_url}/rootfs/bionic.rootfs.ext4"

test -f $desk_kernel || curl -fsSL -o $dest_kernel $kernel
test -f $dest_rootfs || curl -fsSL -o $dest_rootfs $rootfs


kernel="$(pwd)/hello-vmlinux.bin"
rootfs="$(pwd)/hello-rootfs.ext4"
url="http+unix://%2Ftmp%2Ffirecracker.socket"


function fc-put {
    http --check-status -v PUT "$@"
}

boot_args='"console=ttyS0 reboot=k panic=1 pci=off"'

fc-put "${url}/boot-source" kernel_image_path=$kernel "boot_args:=$boot_args"
fc-put "${url}/drives/rootfs" drive_id=rootfs path_on_host=${rootfs} is_root_device:=true is_read_only:=false

fc-put "${url}/actions" action_type=InstanceStart

# shutdown
# http --check-status -v PUT "http+unix://%2Ftmp%2Ffirecracker.socket/actions" action_type=SendCtrlAltDel
