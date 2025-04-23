#!/bin/bash

docker run -it --rm \
    --privileged \
    --shm-size=1gb \
	--name n8n \
	-p 5678:5678 \
