# Basic flux setup

https://fluxcd.io/flux/get-started

# comparison to similar tools (ArgoCD)
# pros
- highly scalable
- cli-only, focused on efficiency and automation over clickops
- designed to integrate with other CNCF projects like flagger and istio https://fluxcd.io/flagger/tutorials/traefik-progressive-delivery/#automated-canary-promotion
- flagger can then automate the release process with canary tests https://fluxcd.io/flagger/usage/how-it-works/
- https://fluxcd.io/flux/#flux-works-well-with
- does what it does, and does it well without trying to do everything e.g. does not come with a ui, ui requires another integration e.g. weave/capacitor
# cons
- requires cicd system to be set up for app promotions to be secure and effective,
    automation workflow setup to promote apps, or integration with flagger is needed to fully benefit,
    e.g. github actions example https://fluxcd.io/flux/use-cases/gh-actions-helm-promotion/

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
flux bootstrap github   --owner="${GITHUB_USER}"   --repository=fleet-infra   --branch=main   --path=./clusters/my-cluster   --personal

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
├── apps
│   ├── base
│   │   └── podinfo
│   │       ├── kustomization.yaml
│   │       ├── namespace.yaml
│   │       ├── release.yaml
│   │       └── repository.yaml
│   ├── production
│   │   ├── kustomization.yaml
│   │   └── podinfo-values.yaml
│   └── staging
│       ├── kustomization.yaml
│       └── podinfo-values.yaml
├── clusters
│   ├── production
│   │   ├── apps.yaml
│   │   ├── flux-system
│   │   │   ├── gotk-components.yaml
│   │   │   ├── gotk-sync.yaml
│   │   │   └── kustomization.yaml
│   │   └── infrastructure.yaml
│   └── staging
│       ├── apps.yaml
│       ├── flux-system
│       │   ├── gotk-components.yaml
│       │   ├── gotk-sync.yaml
│       │   └── kustomization.yaml
│       └── infrastructure.yaml
├── env.sh
├── infrastructure
│   ├── configs
│   │   ├── cluster-issuers.yaml
│   │   └── kustomization.yaml
│   └── controllers
│       ├── cert-manager.yaml
│       ├── ingress-nginx.yaml
│       └── kustomization.yaml
├── LICENSE
├── README.md
└── scripts
    └── validate.sh
```

