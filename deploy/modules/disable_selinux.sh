#!/bin/sh

setenforce 0                                                            # 临时关闭
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config    # 永久禁用