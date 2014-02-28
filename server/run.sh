#!/bin/bash
echo "$1" | sudo docker run -i intermine /bin/bash -c "$2"