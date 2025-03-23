#!/bin/bash
echo "Setting up pipelock-starter..."
docker-compose up --build -d
echo "Metabase is now running at http://localhost:3000"