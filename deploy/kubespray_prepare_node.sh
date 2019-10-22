#!/bin/sh

hostname=`hostname`
sh_dir=`cd "$(dirname "$0")"; pwd`

mod_dir=$sh_dir/modules
cache_dir=$sh_dir/cache/$hostname

mkdir -p $cache_dir

exec_step(){
    if [ $# -lt 1 ]; then
        echo "exec_step failed, you need to pass in a step name"
    fi
    
    step=$1
    script=$mod_dir/$step.sh
    
    if [ -e $cache_dir/$step ]; then
        echo "==[step: $step: skipped]================================="
    else
        echo "==[step: $step: running]================================="
        sh $script
        
        if [ $? -gt 0 ];then
            echo "failed!!!"
            echo "failed!!!"
            echo "failed!!!"
            exit
        else
            touch $cache_dir/$step
        fi
    fi
}

# 创建 hosts 文件

if [ ! -e $sh_dir/hosts ]; then
    echo please set a hosts file in $sh_dir/hosts first
    exit

else
    sys_hosts=`cat /etc/hosts`
    echo $sys_hosts

    IPS=`awk '{print $1}' $sh_dir/hosts`

    if [ -z "$hosts" ];then
        echo empty file of $sh_dir/hosts
    fi

    cat $sh_dir/hosts | while read line
    do
        if [ -n "$line" ] && [[ ! "$sys_hosts" =~ "$line" ]];then
            echo "$line" >> /etc/hosts
        fi
    done

    IPS=`echo $IPS`
fi

# 执行相关步骤
exec_step disable_firewalld
exec_step disable_selinux
exec_step disable_swap
exec_step set_iptables
exec_step install_docker.sh

echo '==[prepare for nodes ok]===================================================='
