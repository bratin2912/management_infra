# Minimal Azure deployment

This directory completes the existing single-VM infrastructure using the supplied deployment specification. It creates one resource group, VNet, subnet, Standard static public IP, NSG, NIC and NSG association, Ubuntu 22.04 Gen2 VM, StorageV2 Standard/LRS account, private `gst-documents` container and container-scoped Blob role assignment. A random suffix supplies storage naming uniqueness. No application containers are deployed by Terraform.

## Configure and deploy

Install Terraform >= 1.7 and < 2, Azure CLI, and create an SSH key if needed. Sign in to an Azure identity with permission to create the resources and role assignments (for example Contributor plus Role Based Access Control Administrator at the appropriate scope). If storage data-plane operations require access, that deployment identity also needs Storage Blob Data Contributor; the VM role does not grant the deploying user access.

```bash
az login
az account show
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit subscription_id, ssh_allowed_cidr, and ssh_public_key_path.
# Match the Azure CLI subscription to subscription_id:
az account set --subscription <subscription-id>
terraform init
terraform fmt -check
terraform validate
terraform plan -out=deployment.tfplan
terraform apply deployment.tfplan
terraform output
```

Only run apply after reviewing the plan. Commit `.terraform.lock.hcl`; state, plans and personal variable files are ignored. State is local initially and must be protected: move it to an access-controlled remote backend with locking before shared production operation. Do not put private keys or credentials in this directory.

Required inputs: `subscription_id`, `ssh_public_key_path`, and `ssh_allowed_cidr` (your public IPv4 address with `/32`, or approved network). Defaults: project `practice-management`, environment `prod`, Central India, Standard_B2s, username `azureadmin`. Azure quota and SKU availability must be checked for your subscription. SSH paths support `~`. The sample subscription and IP are placeholders.

## Security and compatibility

- SSH requires keys and is restricted to the supplied administrator CIDR. Only HTTP 80 and HTTPS 443 are otherwise allowed from the internet. Keep database and worker ports unpublished in Docker Compose.
- The VM has a system-assigned identity with Storage Blob Data Contributor scoped to the single container. Azure RBAC propagation can briefly delay initial Blob access.
- Storage requires HTTPS and TLS 1.2, disables anonymous Blob access and Shared Key authentication, and enables versioning plus 30-day Blob/container soft deletion. Storage uses Azure platform encryption. Its public HTTPS endpoint remains reachable for authenticated requests; this minimal architecture does not add private endpoints.
- Storage account `prevent_destroy` blocks Terraform destruction/replacement while the guard remains in configuration. It is not WORM protection or protection against deletion outside Terraform. No locked immutability policy is configured.
- AzureRM is constrained to the 4.x provider family (>= 4.36), with explicit subscription and Entra data-plane authentication. The container uses `storage_account_id` and its ARM `id` for RBAC. Random is constrained to 3.x (>= 3.7). The generated lockfile pins AzureRM 4.81.0 and Random 3.9.1. See the [provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) and [container documentation](https://registry.terraform.io/providers/hashicorp/azurerm/4.36.0/docs/resources/storage_container).
- Storage names are sanitized and truncated before adding the random suffix so they fit Azure's 24-character limit. If the earlier account already exists in state, changing its name requires replacement and the destruction guard will block the plan; resolve migration and archive preservation before applying.

## Outputs and application setup

Outputs include VM public IP/name, resource group, SSH command, storage account, container name and Blob endpoint. Connect using `terraform output -raw ssh_command` (add `-i` for a nondefault private key). On the VM, wait for bootstrap before deploying:

```bash
sudo cloud-init status --wait
sudo systemctl status docker
docker compose version
```

Bootstrap installs Git, Docker Engine and the Compose plugin, and adds the administrator to the Docker group. Reconnect if group membership has not taken effect. Check `/var/log/cloud-init-output.log` if bootstrap fails; Terraform VM creation does not verify that package installation succeeded.

Clone your application repository, configure its environment securely, and run `docker compose up -d --build`. Configure DNS and HTTPS certificates at your reverse proxy. Use persistent PostgreSQL volumes and arrange tested database backups; this single VM and its disk remain a single point of failure.

Set these application variables from the Terraform outputs:

```dotenv
AZURE_STORAGE_ACCOUNT_NAME=<storage_account_name output>
AZURE_STORAGE_CONTAINER_NAME=gst-documents
GST_BLOB_PREFIX=clients
```

Use `DefaultAzureCredential`/VM managed identity; do not configure a storage account key. Containers must be able to reach Azure IMDS at `169.254.169.254` to acquire managed identity tokens.

Use Blob keys `clients/<clientId>/gst/<financialYear>/<month>/<invoiceId>.pdf`, with the immutable invoice UUID. The application must upload with `conditions: { ifNoneMatch: "*" }` and treat an existing object as a failure. Terraform and the Contributor role do **not** enforce create-only writes: this role permits overwrite and deletion. Versioning is additional recovery protection. Application integration, backups, TLS and deployment are manual follow-up tasks outside this infrastructure configuration.
