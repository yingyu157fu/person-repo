#!/bin/bash
####帮助信息
[[ "$1" ==  "-h" || "$1" ==  "--help" || $# = 0 ]]&& echo "Usage domain" && exit

####判断是否存在域名
! virsh list --all |awk '{print $2}'|grep "^$1$" > /dev/null && echo "Domain "$1" is not exist!" &&exit

####查询虚拟机状态并询问是否执行删除操作
stat=$(virsh list --all|grep $1|awk '{print $3}')
if [ "$stat" ==  "running" ];then
	read -p "$1 id running ,input \"yes\" to delete it:" choise
	[ "$choise" !=  "yes" ] && echo "删除失败，用户取消！" &&exit
fi

####判断是否存在快照
num=$(virsh snapshot-list $1 |grep -c 'snap')
if [ $num -ne 0 ];then
	read -p "$1 is exist snapshots,input \"yes\" to continue delete snapshots:" choise
	[ "$choise" != "yes" ] && echo "删除失败，用户取消！" &&exit
fi

####遍历快照并询问是否执行删除操作
name=$(virsh snapshot-list $1 |awk '/.snap/{print $1}') &>/dev/null
virsh destroy $1 &> /dev/null
for i in $name;do
virsh snapshot-delete $1 $i &> /dev/null
done

####删除虚拟机以及相关文件
location=$(virsh domblklist $1|grep ".qcow2"|awk '{print $2}')
virsh undefine $1 &> /dev/null
rm -rf $location &> /dev/null
echo "删除成功！"
