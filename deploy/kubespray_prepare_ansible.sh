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
exec_step install_docker
exec_step install_kubespray

echo '==[prepare for master ok]===================================================='
echo 'now you can using those cmds to deploy k8s:'
echo ''
echo '  myname=mycluster      # 设置你自己的 cluster 名称'
echo '  cd /opt/kubespray'
echo '  cp -rfp inventory/sample inventory/$myname'
echo "  declare -a IPS=($IPS)"
echo '  CONFIG_FILE=inventory/$myname/hosts.yml python3 contrib/inventory_builder/inventory.py ${IPS[@]}'
echo ''
echo '  # Review and change parameters under ``inventory/cluster_name/group_vars``'
echo '  vim inventory/$myname/hosts.yml'
echo '  vim inventory/$myname/group_vars/all/all.yml'
echo '  vim inventory/$myname/group_vars/k8s-cluster/k8s-cluster.yml'
echo '  vim inventory/$myname/group_vars/k8s-cluster/addons.yml'
echo ''
echo '  # Deploy Kubespray with Ansible Playbook - run the playbook as root'
echo '  # The option `--become` is required, as for example writing SSL keys in /etc/,'
echo '  # installing packages and interacting with various systemd daemons.'
echo '  # Without --become the playbook will fail to run!'
echo '  ansible-playbook -i inventory/$myname/hosts.yml --become --become-user=root cluster.yml'
echo ''
