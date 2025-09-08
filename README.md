# 📘 FastAPI → Docker → Artifact Registry → GKE (Helm) with GitHub Actions

This repository provides a **secure, production-ready starter template** for deploying a simple **FastAPI + Uvicorn** web application to **Google Kubernetes Engine (GKE)**, using:

- **Docker** for containerization  
- **Google Artifact Registry** for image storage  
- **Terraform** for GKE infrastructure provisioning  
- **Helm** for Kubernetes deployments  
- **GitHub Actions** for CI/CD (Build → Staging → Approval → Production)  

---

## 🚀 Features

- **FastAPI Hello World App** (`/` and `/healthz`).  
- **Dockerized** app for consistent builds.  
- **Artifact Registry** for secure image storage.  
- **Private GKE Cluster** (RBAC enabled, private nodes).  
- **Helm Chart** with configurable values:
  - Replica count  
  - Image repository & tag  
  - Service type & port  
- **Environment-Specific Values** (`staging`, `production`).  
- **CI/CD Pipeline**:
  - Builds and pushes Docker images  
  - Deploys automatically to **staging** on each commit  
  - Deploys to **production** only with:
    - Manual approval  
    - Allowed user list  
    - Valid **SemVer tag** (e.g., `v1.0.0`)  
- **Secure Secret Management**:
  - Application secrets stored in **GCP Secret Manager**  
  - Synced into **Kubernetes Secrets** at deploy time  
- **Validation & Testing**:
  - Helm manifests linted (`helm lint`) before deploy  
  - Post-deploy smoke checks  
  - Application logs checked for errors  

---

## 📂 Repository Structure

```text
fastapi-gke-starter/
├─ app/                      # FastAPI app
│  ├─ app.py
│  ├─ requirements.txt
│  └─ Dockerfile
├─ helm/hello-app/           # Helm chart
│  ├─ Chart.yaml
│  ├─ values.yaml
│  └─ templates/
├─ environments/             # Environment-specific values
│  ├─ values-staging.yaml
│  └─ values-production.yaml
├─ infra/terraform/          # Terraform GKE infra
│  ├─ main.tf
│  ├─ variables.tf
│  └─ outputs.tf
├─ .github/workflows/        # CI/CD pipeline
│  └─ cicd.yaml
└─ README.md                 # (this file)
```

---

## ⚙️ Setup & Configuration

### 1. Provision Infrastructure with Terraform

Enable required APIs:

```bash
gcloud services enable container.googleapis.com artifactregistry.googleapis.com secretmanager.googleapis.com
```

Provision the cluster and registry:

```bash
cd infra/terraform
terraform init
terraform apply   -var="project_id=YOUR-GCP-PROJECT"   -var="region=YOUR-REGION"   -var="location=YOUR-REGION"   -auto-approve
```

This creates:
- Artifact Registry (Docker format)  
- Private GKE Cluster with RBAC and Workload Identity  

---

### 2. Create Secrets in GCP Secret Manager

Example:  

```bash
echo -n "s3cr3t" | gcloud secrets create hello-app-secret --data-file=-
```

These will be synced into Kubernetes Secrets during deployment.

---

### 3. Configure GitHub Repository

Set these **repository secrets**:

| Secret Name | Purpose |
|-------------|---------|
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | OIDC provider ID |
| `GCP_SERVICE_ACCOUNT` | Service account email |
| `GCP_PROJECT_ID` | GCP Project ID |
| `GCP_REGION` | GCP region |
| `GCP_ARTIFACT_REPO` | Artifact Registry repo (e.g., `apps`) |
| `GKE_CLUSTER_NAME` | GKE cluster name |
| `GKE_LOCATION` | GKE cluster region/zone |

Optional: Protect **production** environment in GitHub with required reviewers.

---

## 🐳 Application

### Build & Run locally (optional)
```bash
cd app
docker build -t hello-app:local .
docker run -p 8080:8080 hello-app:local
```

Open: [http://127.0.0.1:8080/](http://127.0.0.1:8080/)  

---

## ⛵ Helm Deployment

### Deploy to Staging
```bash
helm upgrade --install stg-hello helm/hello-app   -f environments/values-staging.yaml   --namespace default
```

### Deploy to Production
```bash
helm upgrade --install prod-hello helm/hello-app   -f environments/values-production.yaml   --namespace default
```

---

## 🔄 CI/CD Workflow

### Pipeline Stages

1. **Build**
   - Build Docker image  
   - Push to Artifact Registry  

2. **Deploy to Staging**
   - Run `helm lint`  
   - Sync secrets from GCP Secret Manager  
   - Deploy to GKE  

3. **Approve**
   - Manual approval required  
   - Approver must be in the **allowed list**  

4. **Deploy to Production**
   - Triggered only by **SemVer tag** (`vX.Y.Z`)  
   - Runs the same deploy steps as staging  

---

## ✅ Testing & Verification

### Staging Deployment Check
```bash
gcloud container clusters get-credentials hello-private-gke --location YOUR-REGION
kubectl get deploy,svc | grep stg-hello
kubectl rollout status deploy/stg-hello-hello-app
kubectl port-forward svc/stg-hello-hello-app 8080:80 &
curl -sf http://127.0.0.1:8080/
```

### Production Deployment Check
```bash
git tag v1.0.0 && git push origin v1.0.0
# Approve in GitHub
kubectl get deploy,svc | grep prod-hello
kubectl rollout status deploy/prod-hello-hello-app
kubectl port-forward svc/prod-hello-hello-app 8080:80 &
curl -sf http://127.0.0.1:8080/
```

Logs must be error-free:
```bash
POD=$(kubectl get pods -l app=prod-hello-hello-app -o jsonpath='{.items[0].metadata.name}')
kubectl logs "$POD" | (! grep -E "ERROR|Error|Unhandled")
```

---

## 🧹 Cleanup

When you’re done, destroy all provisioned infrastructure with Terraform:

```bash
cd infra/terraform
terraform destroy   -var="project_id=YOUR-GCP-PROJECT"   -var="region=YOUR-REGION"   -var="location=YOUR-REGION"   -auto-approve
```

This will delete:
- The **GKE cluster**  
- The **Artifact Registry repository**  
- Associated node pools and networking  

> ⚠️ Make sure you want to delete everything before running this command.

---

## 🔐 Security Best Practices

- ✅ No secrets in repo (all from Secret Manager).  
- ✅ Private GKE nodes, RBAC enabled.  
- ✅ Non-root container user.  
- ✅ Helm lint validation.  
- ✅ Manual approval + user allowlist for production.  
- ✅ SemVer tags enforce versioning discipline.  

---

## 📈 Next Steps & Hardening Ideas

- Add **Horizontal Pod Autoscaler (HPA)**.  
- Add **PodDisruptionBudget (PDB)**.  
- Configure **NetworkPolicies**.  
- Integrate container scanning (e.g., **Trivy**).  
- Enable **VPC-SC** for Artifact Registry.  
- Add structured logging and monitoring (Stackdriver).  

---

## 📝 Summary

This template demonstrates **best practices for cloud-native deployments**:  
- **App layer** → FastAPI + Docker  
- **Infra layer** → Terraform + GKE (private, RBAC)  
- **Deployment layer** → Helm  
- **CI/CD** → GitHub Actions (secure, gated)  
- **Secrets** → GCP Secret Manager  

> Use this as a foundation for production-ready microservices on GKE.  
