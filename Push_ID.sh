#!/bin/zsh

cat /opt/jc/jcagent.conf | grep -o '"systemKey":"[^"]*' | awk -F ':"' '{print $2}'
