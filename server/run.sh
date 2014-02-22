#!/bin/bash
echo "$1" | sudo docker run -i imjs /bin/bash -c "$2"