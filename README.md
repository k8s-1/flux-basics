# Basic flux setup

https://fluxcd.io/flux/get-started

# comparison to similar tools (ArgoCD)
# pros
- highly scalable
- cli-only, focused on efficiency
- designed to integrate with other CNCF projects like flagger and istio https://fluxcd.io/flagger/tutorials/traefik-progressive-delivery/#automated-canary-promotion
- flagger can then automate the entire release process with canary tests https://fluxcd.io/flagger/usage/how-it-works/
# cons
- requires cicd system to be set up for app promotions to be secure and effective,
    i.e. automation workflows to promote apps, custom automation is needed to fully benefit

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

# useful commands
```
# preview what flux will build -> similar to kustomize build .
flux build kustomization podinfo --path . --kustomization-file ./podinfo-kustomization.yaml --dry-run

# create a flux kustomization on the fly
kustomize create <name> -h --export
```

# simplified, scalable repository structure
* base contains base manifests
* clusters contains clusters (e.g. dev, prod)
* each cluster folder contains apps folders
* each app folder contains environment-specific yaml:
    - flux kustomization
    - env-specific resources e.g. secret.yaml
    - kustomization patches for the base config
* enables separate flux bootstrapping on cluster-basis (this structure is essentially forced by design)
* each tenant/team/app should be reconciled by its own Kustomization, flux was designed this way (stefanprodan - flux maintainer)
```
.
├── base # base config for overlays
│   ├── app1
│   │   ├── deployment.yaml
│   │   ├── middleware.yaml
│   ├── app2
│   │   ├── deployment.yaml
│   │   ├── middleware.yaml
├── clusters
│   └── dev
│       ├── app1
│       │   ├── patch-deployment.yaml
│       │   ├── secret.yaml
│       │   └── kustomization.yaml
│       ├── app2
│       │   ├── patch-deployment.yaml
│       │   ├── secret.yaml
│       │   └── kustomization.yaml
│   └── prod
│       ├── app1
│       │   ├── patch-deployment.yaml
│       │   ├── secret.yaml
│       │   └── kustomization.yaml
│       ├── app2
│       │   ├── patch-deployment.yaml
│       │   ├── secret.yaml
│       │   └── kustomization.yaml
└── README.md
```

