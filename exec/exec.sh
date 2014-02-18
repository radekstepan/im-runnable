#!/bin/bash
less $2 | sudo docker run -i imjs /bin/bash -c "cat > script; $1 script"