#!/bin/sh

swapoff -a                          # 临时关闭
sed -i 's/.*swap.*/#&/' /etc/fstab  # 永久禁用