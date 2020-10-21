#!/bin/bash

docker build -t qmin:latest .
docker run -p 8000:8000 --name qmin qmin:latest
