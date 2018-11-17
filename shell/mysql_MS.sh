#!/bin/bash
while true
do
array=($(mysql -u root -p'123' -e "show slave status\G"|egrep '_Running|Behind_Master|Last_SQL_Errno'|awk '{print $NF}'))
if [ "${array[0]}" == "Yes" -a "${array[1]}" == "Yes" -a "${array[2]}" == "0" ]
	then
		echo "MySQL is slave is ok"
	else
		if [ "${array[3]}" -ne 0 ] ; then
		mysql -u root -p'123' -e "stop slave &&set global sql_slave_skip_counter=1;start slave;"
		echo "错误代码${array[3]}"
		fi
			char="MySQL slave is not ok,错误代码${array[3]}"
			echo "$char"
			echo "$char"|mail -s "$char" 1434050231@qq.com
		fi
		sleep 60
done
