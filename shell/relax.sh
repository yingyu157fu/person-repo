#!/bin/bash
function kaishi(){
  echo -e "\033[3;34m欢迎来到国庆大餐～\033[0m"
  echo -e "\033[31m-----------------\033[0m"
  echo -e "\033[1;4;3;33m    1: 注册    \033[0m  " 
  echo -e "\033[1;4;3;33m    2: 登录    \033[0m  "
  echo -e "\033[1;4;3;33m    3: 退出    \033[0m  "
  echo -e "\033[31m-----------------\033[0m"
echo -n "请选择您的服务类型："
}

function username(){
		echo -n "    用户名：";
		read username;
}
function password(){
		echo  -n "    密  码：";
		read -s password1
		echo
		echo -n "    确认密码："
		read -s password2;
		echo;
}
function testpw(){
	password
	if [ $password1 -eq $password2 ];then
	 let password1=password2;
	else 
	 echo "密码错误，请重新输入！"
	 continue
	fi
}
function useradd (){
	while :
	do
	username
	testpw
	mysql -u root -D user -e "insert into m set username='$username',password=password($password1)"  &> /dev/null
	if [ $? -ne 0 ]
	then
        	echo "exist,please use other name!";
		continue;
	else
		echo "success!back to memu...";
	mysql -u root -D user -e "insert into b set user='$username',balance='100'" &>/dev/null
		break
	fi
	done
}
function load(){
	num=1
	while :;do
	[ $num -gt 3 ]&& break
	echo -n "    用户名：";
	read name;
	echo  -n "    密  码：";
	read -s password3
	echo
	name1=`mysql -D user -e "select username from m where username='$name'"|sed -nr '2p'`
	pw=`mysql -D user -e "select password($password3)"|sed -nr '2p'`
	pwr=`mysql -D user -e "select password from m where username='$name'"|sed -nr '2p'|awk '{print $0}'`
	if [ "$name" != "$name1" ];then
		echo "用户名不正确！"
	elif [ "$pw" != "$pwr" ];then
		echo "密码不正确！"
	else
		echo "正在跳转主界面..."&& 
		menu
		exit
	fi
	let num++
	done
	echo "您的密码输入次数过多..."
	sleep 2
	kaishi
}
function main(){
	echo -n "1: 返回主菜单"
	echo  "2: 退出"
	echo  -n "您好，请选择服务类型："
	read n
		case $n in
		1)
			menu
			;;
		2)
			echo "正在退出..."
			sleep 1
			exit
			;;
		esac
}
function chaxun(){
	count=`mysql -D user -e "select balance from b where user='$name'"|sed -nr '2p'|awk '{print $0}'`
	echo "$count"
}
function chongzhi(){
	while :;do
	count=`mysql -D user -e "select balance from b where user='$name'"|sed -nr '2p'|awk '{print $0}'`
	echo -n "请输入您要充值的数目："
	read num
	sum=$[$count+$num]
	let yu=$num%50
	if [ $yu -eq 0 ];then
		echo "充值成功！您的余额为$sum"
		mysql -D user -e "update b set balance=$sum where user='$name'"
		main
	else
		echo "数目需要50的整数倍，请重新选择数额！"
		
	fi
	done
}
function xiaofei(){
	count=`mysql -D user -e "select balance from b where user='$name'"|sed -nr '2p'|awk '{print $0}'`
	echo -n "请选择您想购买的数量："
	read d
	last=$[$count-$d]
	if [ $last -ge 0 ];then
		echo "恭喜购买成功！花费$d元，您的余额为$last"
		mysql -D user -e "update b set balance=$last where user='$name'"
	else 
		echo "您的余额不足，请充值！"
		chongzhi
	fi
}
function menu(){
	echo -n "1：查询"
	echo -n " 2: 充值"
	echo " 3: 消费"
	echo  -n "您好，请选择服务类型："
	read m
		case $m in
		1)
			chaxun
			main
			;;
		2)
			chongzhi
			main
			;;
		3)
			xiaofei
			main
			;;
		*)
			echo "false"
			exit
			;;
		esac
}
kaishi
while :
do
read i
	case $i in
	1)
		useradd 
		sleep 1
		kaishi
		;;
	2)
		load
		;;
	3)
		echo -n "正在退出";
		sleep 1;
		echo -n ".";
		sleep 1;
		echo -n ".";
		sleep 1;
		echo ".";
		exit;
		;;
	*)
		echo "wrong number!";
		exit;
		;;
	esac
done 2> /dev/null
