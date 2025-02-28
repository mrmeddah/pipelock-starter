#!/bin/bash
cd ~/pipelock-starter
npm install
wasp db start &
wasp start --bind 0.0.0.0:3000 &
