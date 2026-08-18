# EKS Fargate Terraform

Self-contained Terraform project that provisions an Amazon EKS cluster
running entirely on **AWS Fargate** (no EC2 worker nodes, no node groups,
no Auto Mode).

## Why Fargate here

- No EC2 instances, launch templates, AMIs, or node patching to manage.
- Pods run in per-namespace/per-label Fargate profiles — isolated compute
  per pod, billed per pod.
- Still requires the standard cluster add-ons (`coredns`, `kube-proxy`,
  `vpc-cni`) to be scheduled onto Fargate explicitly (handled below).

## Layout

```
main.tf             # Root module wiring: network -> iam -> cluster -> fargate profiles -> addons
providers.tf         # AWS provider
backend.tf           # Remote state (S3)
variables.tf         # Root input variables
outputs.tf           # Root outputs
terraform.tfvars.example
modules/
  network/           # VPC, public+private subnets, IGW, NAT, route tables
  iam/                # Cluster role + Fargate pod execution role
  cluster/            # aws_eks_cluster (private endpoint, KMS-encrypted secrets)
  fargate/            # aws_eks_fargate_profile(s)
  addons/              # aws_eks_addon (coredns, kube-proxy, vpc-cni) patched for Fargate
```

## Fargate-specific requirements handled

1. **Pod execution role** (`modules/iam`) — trust policy for
   `eks-fargate-pods.amazonaws.com`, attached to
   `AmazonEKSFargatePodExecutionRolePolicy`.
2. **Private subnets only** — Fargate profiles may only reference private
   subnets (no `map_public_ip_on_launch`, no direct IGW route).
3. **CoreDNS on Fargate** — a Fargate profile matching
   `kube-system` / `k8s-app=kube-dns` is created *before* the `coredns`
   addon so CoreDNS pods can actually schedule; the addon is applied with
   `resolve_conflicts_on_update = "OVERWRITE"`.
4. **No `kube-proxy`/`vpc-cni` daemonsets to worry about on Fargate nodes**
   — Fargate pods get networking via the VPC CNI in Fargate mode
   automatically; the `vpc-cni` addon still manages ENI config for the
   control plane / any EC2 nodes if you add them later.
5. **Default Fargate profile** — a second profile matches
   `namespace = default` (edit `var.fargate_profiles` to add your own
   namespaces/selectors).

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars: project_name, env_subfix, cluster_name, tags, backend bucket

terraform init
terraform plan
terraform apply
```

## Adding your own workloads

Add a new entry to `var.fargate_profiles` for each namespace (or
namespace+label selector) you want scheduled on Fargate:

```hcl
fargate_profiles = {
  kube-system = {
    selectors = [{ namespace = "kube-system", labels = { "k8s-app" = "kube-dns" } }]
  }
  default = {
    selectors = [{ namespace = "default", labels = {} }]
  }
  my-app = {
    selectors = [{ namespace = "my-app", labels = {} }]
  }
}
```

Every namespace you run pods in **must** have a matching Fargate profile,
or those pods will stay `Pending` forever (no EC2 nodes exist to fall back
to).
