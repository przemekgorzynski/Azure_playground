# Azure Landing Zone

Hub-and-spoke network landing zone deployed across three Azure subscriptions. Two IaC implementations are provided — Terraform and Terragrunt — both using Terraform Cloud as the state backend.

## Architecture

```
Management subscription (hub)
├── rg-VnetHub-internal-we
│   ├── vnet-hub-internal-we        10.0.0.0/16
│   │   ├── Hub-mgmnt-subnet        10.0.1.0/24
│   │   ├── Hub-pe-subnet           10.0.2.0/24
│   │   └── Hub-nva-subnet          10.0.3.0/28  (optional NVA)
│   └── nsg-hub-internal-we
└── rg-DnsHub-internal-we
    └── privatelink.blob.core.windows.net
        ├── dns-link-hub
        ├── dns-link-spoke1
        └── dns-link-spoke2

Spoke 1 subscription
└── rg-VnetSpoke1-internal-we
    ├── vnet-spoke1-internal-we     10.1.0.0/16
    │   ├── subnet-pe               10.1.1.0/24
    │   └── subnet-02               10.1.2.0/24
    ├── nsg-spoke1-internal-we
    └── rt-spoke1-internal-we
        ├── 0.0.0.0/0  → Internet
        └── 10.0.0.0/16 → VnetLocal

Spoke 2 subscription
└── rg-VnetSpoke2-internal-we
    ├── vnet-spoke2-internal-we     10.2.0.0/16
    │   ├── subnet-pe               10.2.1.0/24
    │   └── subnet-02               10.2.2.0/24
    ├── nsg-spoke2-internal-we
    └── rt-spoke2-internal-we
        ├── 0.0.0.0/0  → Internet
        └── 10.0.0.0/16 → VnetLocal
```

**VNet peerings** (bidirectional):
- `vnet-hub` ↔ `vnet-spoke1`
- `vnet-hub` ↔ `vnet-spoke2`

## Subscriptions

| Name | Subscription ID | Purpose |
|------|----------------|---------|
| Management | `498ff788-a1a1-4860-a97f-3ee90d4fab61` | Hub VNet, DNS, shared services |
| Spoke 1 | `4d0f2de4-fd44-4c94-ab45-5d8f2d2b3720` | Workload environment 1 |
| Spoke 2 | `fa2293f5-402a-453a-a8da-0870c83a6122` | Workload environment 2 |

## Prerequisites

- Terraform >= 1.6
- Terragrunt >= 1.0
- Terraform Cloud account (`pszemazzz` organisation)
- Service principal with Contributor rights on all three subscriptions

## Setup

Create `Terraform/.env` (shared by both implementations):

```bash
export ARM_CLIENT_ID=<service-principal-app-id>
export ARM_CLIENT_SECRET=<service-principal-secret>
export ARM_TENANT_ID=<tenant-id>
export TF_TOKEN_app_terraform_io=<terraform-cloud-api-token>

export ARM_MGMT_SUBSCRIPTION_ID=<management-subscription-id>
export ARM_SPOKE1_SUBSCRIPTION_ID=<spoke1-subscription-id>
export ARM_SPOKE2_SUBSCRIPTION_ID=<spoke2-subscription-id>
```

---

## Terraform

Single-workspace implementation. All three subscriptions are managed in one Terraform root module using provider aliases, with a single TF Cloud workspace (`Landing_Zone`).

### Structure

```
Terraform/
├── provider.tf    # AzureRM provider aliases per subscription + TF Cloud backend
├── hub.tf         # Hub RGs, VNet, subnets, NSG, optional NVA
├── spoke1.tf      # Spoke 1 RGs, VNet, subnets, NSG, route table
├── spoke2.tf      # Spoke 2 RGs, VNet, subnets, NSG, route table
├── peering.tf     # Bidirectional VNet peerings hub ↔ spoke1/2
├── dns.tf         # Private DNS zones + VNet links to all three VNets
├── variables.tf   # Input variable declarations
├── lz.tfvars      # All variable values
└── run.sh         # Wrapper script
```

### Usage

```bash
cd Terraform
./run.sh init
./run.sh plan
./run.sh apply
./run.sh destroy
```

### NVA (optional)

A Linux VM (`Standard_B2ats_v2`, Ubuntu 22.04 LTS) on `Hub-nva-subnet` (`10.0.3.4`) for traffic forwarding between spokes. Disabled by default.

```hcl
# lz.tfvars
deploy_nva = true
```

---

## Terragrunt

Per-subscription implementation. Each subscription is a separate Terragrunt unit with its own TF Cloud workspace, using `generate` blocks to produce provider and resource configs at runtime.

### Structure

```
Terragrunt/
├── root.hcl        # Common backend, variables, and locals shared by all units
├── hub/
│   └── terragrunt.hcl   # Hub subscription — workspace: Landing-Zone-hub
├── spoke1/
│   └── terragrunt.hcl   # Spoke 1 subscription — workspace: Landing-Zone-spoke1
├── spoke2/
│   └── terragrunt.hcl   # Spoke 2 subscription — workspace: Landing-Zone-spoke2
└── run.sh               # Wrapper script
```

### TF Cloud workspaces

| Unit | Workspace |
|------|-----------|
| hub | `Landing-Zone-hub` |
| spoke1 | `Landing-Zone-spoke1` |
| spoke2 | `Landing-Zone-spoke2` |

### Usage

```bash
cd Terragrunt

# all subscriptions
./run.sh plan
./run.sh apply
./run.sh destroy

# single subscription
./run.sh plan   hub
./run.sh apply  spoke1
./run.sh destroy spoke2
```

---

## NSG rules (default — same for hub and both spokes)

| Rule | Priority | Direction | Action | Details |
|------|----------|-----------|--------|---------|
| allow-ssh | 100 | Inbound | Allow | TCP/22, any source |
| allow-forward | 200 | Inbound | Allow | Any protocol, `10.0.0.0/8` → `10.0.0.0/8` |
| allow-icmp | 300 | Inbound | Allow | ICMP, `10.0.0.0/8` → `10.0.0.0/8` |

## Modules

All modules are sourced from `../../modules/terraform/`:

| Module | Used by |
|--------|---------|
| `resource_group` | all |
| `vnet` | all |
| `subnet` | all |
| `nsg` | all |
| `route_table` | spokes |
| `vnet_peering` | hub |
| `private_dns_zone` | hub |
| `linux_vm` | hub (NVA) |
