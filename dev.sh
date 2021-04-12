#!/bin/sh
# coding:utf-8
# Copyright (C) 2019-2021 All rights reserved.
# FILENAME:  dev.sh
# VERSION: 	 1.0
# CREATED: 	 2021-04-05 11:23
# AUTHOR: 	 Aekasitt Guruvanich <sitt@coinflex.com>
# DESCRIPTION:
#
# HISTORY:
#*************************************************************

CMD=${1:up}

shift

if [ "$CMD" == 'build' ];
then
  docker build --tag smartbch .
elif [ "$CMD" == 'clear' ];
then
  if [ ! -z $(docker images -f dangling=true -q) ];
  then
    docker rmi $(docker images -f dangling=true -q)
  else
    echo 'No dangling images'
  fi
elif [ "$CMD" == 'down' ];
then
  docker-compose down
elif [ "$CMD" == 'gen-test-keys' ];
then
  # Generate a set of n test keys.
  echo $(docker-compose run smartbch gen-test-keys | tr -s '[:space:]' '\r')  >> test-keys.txt
elif [ "$CMD" == 'init' ];
then
  # Init the node, include the keys from the last step as a comma separated list.
  docker-compose run smartbch init mynode --chain-id 0x1 --init-balance=10000000000000000000 --test-keys="$(cat test-keys.txt | tr '\r' ',' | sed 's/,$//g')"
elif [ "$CMD" == 'up' ];
then
  # Start it up, you are all set!
  docker-compose up
fi
