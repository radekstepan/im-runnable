#!/bin/bash
echo "$1" | sudo docker run -i imjs /bin/bash -c "cat > script; $2 script"