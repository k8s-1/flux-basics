# Basic flux setup

https://fluxcd.io/flux/get-started

# requirements
A Kubernetes cluster. We recommend Kubernetes kind for trying Flux out in a local development environment.
A GitHub personal access token with repo permissions. See the GitHub documentation on creating a personal access token.

# export vars
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=<your-username>

# install flux
curl -s https://fluxcd.io/install.sh | sudo bash

# start cluster
kind create cluster

flux check --pre
flux bootstrap github   --owner=   --repository=fleet-infra   --branch=main   --path=./clusters/my-cluster   --personal
