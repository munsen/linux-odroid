#!/usr/bin/env bash

# after build kernel using make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc) -j 16
# Run this script on N2

version=$(make kernelrelease)
echo $1
if [ -n "$1" ]; then
  target_dir=$1/${version}
else
  target_dir=/media/boot/${version}
fi

mkdir -p ${target_dir}/amlogic/overlays
rsync -r --delete --progress --include='*/' --include='meson64_odroid*.dtb' --include='overlays/*/*.dtbo' --exclude='*' arch/arm64/boot/dts/amlogic/ ${target_dir}/amlogic/

cp arch/arm64/boot/Image.gz -t /boot
cp /boot/Image.gz -t ${target_dir}
sudo make modules_install
update-initramfs -c -k $version
mkimage -A arm64 -O linux -T ramdisk -C none -a 0 -e 0 -n uInitrd -d /boot/initrd.img-$version /boot/uInitrd-$version
sudo rm scripts/basic/fixdep scripts/unifdef
sudo make headers_install
cp /boot/uInitrd-$version $target_dir/uInitrd
