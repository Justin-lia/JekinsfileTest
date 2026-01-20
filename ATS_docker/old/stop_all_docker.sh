#!/bin/bash
cd docker_ats && docker compose down
cd ..


docker network prune -f
