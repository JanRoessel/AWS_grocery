# Infrastructure as Code (Terraform)

Defines the AWS resources this project runs on: EC2 (Docker host), RDS
PostgreSQL (private), S3 (avatar storage), an Application Load Balancer, and
the IAM/Security Group wiring between them. Written for **Woche 6** of the
Masterschool curriculum.

Uses the account's **default VPC/subnets** (see `main.tf`) rather than a
custom network - matches what Woche 2 already set up manually and keeps this
project's scope focused on compute/data/storage rather than networking.

## Layout

| File | Defines |
|---|---|
| `main.tf` | Provider, default VPC/subnet/AMI lookups |
| `variables.tf` | All configurable inputs (region, instance sizes, secrets, …) |
| `security_groups.tf` | ALB → EC2 → RDS traffic chain, least-privilege |
| `iam.tf` | EC2 instance role with S3 read/write on this project's bucket only |
| `s3.tf` | Avatar storage bucket, versioned, private, lifecycle-managed |
| `rds.tf` | Private PostgreSQL instance (no public IP) |
| `ec2.tf` + `ec2_user_data.sh.tpl` | App server: installs Docker, builds & runs this repo's own `Dockerfile` |
| `alb.tf` | Public entry point, health-checks `/health` |
| `outputs.tf` | Prints the live app URL, RDS endpoint, S3 bucket name after apply |

## Usage

```bash
cd infrastructure
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars: key_pair_name, s3_bucket_name
# set secrets via env vars instead of the file:
export TF_VAR_db_password="something-strong"
export TF_VAR_jwt_secret_key="something-random"

terraform init
terraform plan
terraform apply
```

After `apply`, `terraform output alb_dns_name` gives you the public URL.
The EC2 instance takes a minute or two after boot to finish installing
Docker and building the image - check target group health in the AWS
Console (EC2 → Target Groups) once it's up.

To tear everything down again (avoid ongoing costs):

```bash
terraform destroy
```

## Relationship to the manually-created resources

Weeks 2–7 of this course had you click EC2/RDS/S3/ALB together by hand in
the AWS Console first, to learn what each service does before automating it.
This Terraform config defines the **same architecture as code** so it's
reproducible - it provisions its own parallel set of resources rather than
importing the manually-created ones (importing existing resources into
Terraform state is possible via `terraform import` but is a separate,
optional step not required for this assignment).
