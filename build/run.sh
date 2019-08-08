#!/bin/sh
docker run -d -it -p 8080:80 --name=www_debug nginx-php
