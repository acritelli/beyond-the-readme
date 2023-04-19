# Sidecar Container Deep Dive

These instructions describe the configuration of Vault used in the sidecar deep dive video. They assume that you already have a [K3s installation](https://k3s.io/) deployed.

## Vault installation

Install HashiCorp Vault using the [official Helm chart](https://developer.hashicorp.com/vault/docs/platform/k8s/helm) and the `values.yaml` file in this repository.

```
helm repo add hashicorp https://helm.releases.hashicorp.com

helm install -f values.yaml vault hashicorp/vault
```

Apply the `ConfigMap.yaml` to customize the Vault agent configuration.

```
kubectl apply -f ConfigMap.yaml
```

## Enable Vault Kubernetes authentication

Enable Vault Kubernetes installation using the steps below. These steps **are not** intended for use in a production environment.

First, download the CA certificate for the Kubernetes cluster:

```
echo | openssl s_client -connect localhost:6443 2>/dev/null | openssl x509 > ca.crt 2>/dev/null
```

Next, enable and configure the Kubernetes authentication method. This can be done from within the Vault Pod, as long as you copy the `ca.crt` file into the pod.

Copy the `ca.crt` file into the Vault pod:

```
kubectl cp ca.crt vault-0:/vault/
```

Enable the Kubernetes authentication method:
```
kubectl exec vault-0 -- vault auth enable kubernetes

kubectl exec vault-0 -- vault write auth/kubernetes/config \
    kubernetes_host=https://kubernetes \
    kubernetes_ca_cert=@/vault/ca.crt
```

Next, create a new Vault policy called `secret-reader` that grants read and list capabilities on the `secret/*` path.

```
# Create policy
cat > secret-reader.hcl << EOF
path "secret/*" {
    capabilities = ["read", "list"]
}
EOF

# Copy policy to Vault container
kubectl cp secret-reader.hcl vault-0:/vault/secret-reader.hcl

# Write policy into Vault
kubectl exec vault-0 -- vault policy write secret-reader /vault/secret-reader.hcl
```

Finally, associate the Vault policy with the default Kubernetes service account. 

**NOTE:** Just to repeat, this is unsafe for production use. You should always use specific Kubernetes service accounts in production. This is only done for example purposes.

```
kubectl exec vault-0 -- vault write auth/kubernetes/role/secret-reader \
    bound_service_account_names=default \
    bound_service_account_namespaces=default \
    policies=secret-reader \
    ttl=1h
```

Finally, create a secret for testing purposes:

```
kubectl exec vault-0 -- vault kv put secret/api_key value=ThisIsASecretAPIKey
```
