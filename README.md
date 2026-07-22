# AWS Grocery Store

Dieses Projekt ist meine **Masterschool Cloud Engineering Projektarbeit** (Mai–Juli 2026).

Ich habe eine bestehende E-Commerce-Anwendung (GroceryMate) genommen und auf AWS deployed — mit Docker-Containerisierung und Infrastructure as Code (Terraform).

## Meine AWS-Architektur

```
Internet
    ↓
[Application Load Balancer]
    ↓
[EC2 Instance (Docker)]
    ├── → [RDS PostgreSQL] (privat)
    └── → [S3 Bucket] (Avatare)

[CloudWatch Alarme] ← Monitoring
```

## Was ich gemacht habe

| Service | Was | Status |
|---------|-----|--------|
| **EC2** | App-Server mit Docker auf t3.micro | ✅ |
| **RDS** | PostgreSQL in privatem Subnet | ✅ |
| **S3** | Bucket für User-Avatare (versioniert, Lifecycle) | ✅ |
| **ALB** | Load Balancer mit Health Checks | ✅ |
| **Docker** | Multi-Stage Dockerfile + docker-compose | ✅ |
| **Terraform** | Ganze Infrastruktur als Code | ✅ |
| **CloudWatch** | CPU/Disk/ALB-Alarme | ✅ |
| **IAM** | Least-Privilege Role für EC2 → S3 | ✅ |

## Docker lokal ausführen

```bash
git clone https://github.com/JanRoessel/AWS_grocery.git
cd AWS_grocery
docker compose up --build
# App unter http://localhost:8080
```

## Auf AWS deployen

Terraform vorausgesetzt:

```bash
cd infrastructure/
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars ausfüllen (DB-Passwort, JWT-Key, S3-Bucket-Name, Key-Pair)
terraform init
terraform plan
terraform apply
```

Nach dem Apply zeigt `terraform output alb_dns_name` die URL.

## Was ich gelernt habe

- Security Groups sind stateful — aber man muss trotzdem Inbound-Regeln richtig setzen
- Docker-Permissions auf Amazon Linux: `sudo usermod -aG docker ec2-user` + neu einloggen
- IAM Instance Roles sind besser als feste API-Keys in .env
- Terraform State sollte man im Team in S3 ablegen (fürs Bootcamp reicht lokal)
- ALB Health Checks: der Pfad muss zum App-Endpoint passen (`/health`)

## Kosten (ca. $17/Monat)

- EC2/RDS: Free Tier (t3.micro)
- ALB: ~$16.50 (teuerster Posten, aber nötig)
- S3 + CloudWatch: < $0.50

## Repo-Struktur

```
AWS_grocery/
├── infrastructure/       # Terraform IaC
│   ├── main.tf          # Provider + VPC
│   ├── ec2.tf           # EC2 Instance
│   ├── rds.tf           # RDS PostgreSQL
│   ├── alb.tf           # Application Load Balancer
│   ├── s3.tf            # S3 Bucket
│   ├── cloudwatch.tf    # CloudWatch Alarme
│   ├── iam.tf           # IAM Roles
│   ├── security_groups.tf
│   ├── variables.tf
│   └── outputs.tf
├── backend/              # Flask Backend
├── frontend/             # React Frontend
├── Dockerfile            # Multi-Stage Build
└── docker-compose.yml    # Lokale Entwicklung
```

## Offene Punkte (Woche 9–11)

- [ ] Screenshots von allen Services machen
- [ ] Praxisprüfungen 5 + 6 (Ziel 90%)
- [ ] Interne MSIT-Prüfungen (70% / 80%)
- [ ] AWS CLF-C02 Zertifizierung
