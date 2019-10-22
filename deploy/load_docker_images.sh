#!/bin/sh

if [ $# -eq 0 ]; then
    echo please input a images dir 
    exit
fi

if [ -d $1 ]; then

    files=`ls $1`

    for file in $files
    do
        echo loading $1/$file ...

        docker load --input $1/$file
    done

else
    echo "dir $1 not exist or not a dir" 
    exit
fi
