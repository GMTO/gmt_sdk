#!/bin/bash
TAG=${1:-nightly}
docker build . --file Dockerfile -t ghcr.io/gmto/gmt-sdk:$TAG