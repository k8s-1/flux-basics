age-keygen -o age.agekey


cat age.agekey |
kubectl create secret generic sops-age \
--namespace=flux-system \
--from-file=age.agekey=/dev/stdin


kubectl create secret generic mysecret --dry-run=client -oyaml --from-literal foo=bar > basic-auth.yaml


sops --age=age15nmgt4rdjw0jjj2l5lcw373tw50vw7q4mvt4a4xcj0k7atw5p4zqx3hk8e --encrypt --encrypted-regex '^(data|stringData)$' --in-place basic-auth.yaml


flux-kustomization.yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: podinfo
  namespace: flux-system
spec:
  interval: 60m
  path: ./infra/podinfo
  prune: true
  decryption:
    provider: sops
    secretRef:
      name: sops-age
