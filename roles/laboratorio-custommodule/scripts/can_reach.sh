#!/bin/bash
host=$1
port=$2
timeout=$3

nc -w $timeout -v $host $port </dev/null; echo $?