#!/bin/sh

images=`docker images | awk '{if(NR>1) printf("%s:%s\n", $1, $2)}'`

mkdir -p ./images/cache

for image in $images
do
    echo saving $image ...

    name=`echo $image | sed 's/\//_/g'`
    name=`echo $name  | sed 's/\:/_/g'`
    docker save $image >./images/cache/$name.tar
    tar -zcf ./images/$name.tar.gz -C ./images/cache/ $name.tar

done
