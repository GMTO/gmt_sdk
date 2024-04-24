#!/bin/bash
TAG=${1:-nightly}
docker push ghcr.io/gmto/gmt-sdk:$TAG