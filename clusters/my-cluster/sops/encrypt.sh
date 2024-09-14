#!/bin/bash


# generate age key
rm -i age.agekey
age-keygen -o age.agekey


# create decryption secret
kubectl delete secret sops-age -n flux-system
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


# check if decryption works
echo "Verifying decryption..."
export SOPS_AGE_KEY_FILE=age.agekey
sops -d basic-auth.yaml

