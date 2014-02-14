#!/bin/bash
less ./scripts/$1 | sudo docker run -i imjs /bin/bash -c "cat > script.js; node script.js"