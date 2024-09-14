#!/bin/bash

# generate age key
age-keygen -o age.agekey

# create decryption secret
kubectl create secret generic sops-age \
    --namespace=flux-system \
    --from-file=age.agekey

# generate secret yaml
cat <<EOF> basic-auth.yaml
apiVersion: v1
data:
  foo: YmFy
kind: Secret
metadata:
  name: mysecret
EOF

# encrypt secret yaml
sops --age="$(grep "public key" age.agekey | awk '{print $NF}')" \
    --encrypt \
    --encrypted-regex '^(data|stringData)$' \
    --in-place basic-auth.yaml
