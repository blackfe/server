#!/bin/sh
i=1
for i in `seq 1`
do
    echo $i
      ../skynet/3rd/lua/lua ./client.lua
done
