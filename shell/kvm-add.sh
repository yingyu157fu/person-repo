#!/bin/bash
[ "$1" == "--help" ]||[ "$1" == "-h" ]||[ "$1" == ""  ] &&echo "[Usage]:domain name size"&&exit;
#在客户端查看磁盘
domain=$1
name=$2
size=$3
##新建qcow2格式磁盘
qemu-img create -f qcow2 /kvm/disk/$name.qcow2 $size &> /dev/null
if [ $? -eq 0 ];then
echo "$name磁盘已经新建成功！"
else
echo "$name磁盘未成功！"
exit
fi
#编写对应的xml文件$name.xml
cp /etc/libvirt/qemu/default.xml /etc/libvirt/qemu/$name.xml
sed -i "s/default/$name/" $name.xml
n=`ansible $domain -m shell -a "lsblk"|awk '/^sd/{print $1}'|tail -1|sed -nr 's/^..//p'`
a=({a..z})
for i in ${!a[*]};do [ "${a[$i]}" == "$n" ]&&let m=$i+1&&break;done
sed -i "s/sdb/sd${a[$m]}/" $name.xml
echo "已创建sd${a[$m]}"
#创建磁盘
cd /etc/libvirt/qemu
virsh attach-device $domain $name.xml
#挂载磁盘
ansible $domain -m shell -a "parted /dev/sd${a[$m]} mkpart primary 1 $size"
ansible $domain -m shell -a "mkfs.xfs /dev/sd${a[$m]}"
ansible $domain -m shell -a "mkdir /mnt/cdrom${a[$m]}"
ansible $domain -m shell -a "mount /dev/sd${a[$m]} /mnt/cdrom${a[$m]}"
echo "挂载成功"

