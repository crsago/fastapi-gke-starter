# FastAPI → Docker → Artifact Registry → GKE (Helm) with GitHub Actions

A secure-by-default starter:
- FastAPI + Uvicorn Hello World
- Docker image to Google Artifact Registry
- Private GKE cluster via Terraform (RBAC enabled)
- Helm chart with configurable replicaCount, image repo/tag, service type/port
- Staging on each push; Production via manual approval + allowed user list + SemVer tag
- Secrets sourced from GCP Secret Manager, synced into Kubernetes Secrets
- `helm lint` gate; simple smoke checks after deploy

## Quick start

### 1) Provision infra
```bash
cd infra/terraform
terraform init
terraform apply -var="project_id=YOUR-GCP-PROJECT" -var="region=YOUR-REGION" -var="location=YOUR-REGION" -auto-approve
```

### 2) Create a secret
```bash
echo -n "s3cr3t" | gcloud secrets create hello-app-secret --data-file=-
```

### 3) Configure GitHub OIDC/WIF and repo secrets
Set the following repository secrets:
- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_SERVICE_ACCOUNT`
- `GCP_PROJECT_ID`
- `GCP_REGION`
- `GCP_ARTIFACT_REPO` (e.g., `apps`)
- `GKE_CLUSTER_NAME` (e.g., `hello-private-gke`)
- `GKE_LOCATION` (region or zone)

### 4) Push code
On push:
- build → push image → deploy to **staging**
On SemVer tag (e.g., `v1.0.0`):
- requires manual approval + username allowlist → deploy to **production**

### 5) Verify
```bash
gcloud container clusters get-credentials hello-private-gke --location YOUR-REGION
kubectl get deploy,svc | grep stg-hello
kubectl rollout status deploy/stg-hello-hello-app
kubectl port-forward svc/stg-hello-hello-app 8080:80 &
curl -sf http://127.0.0.1:8080/
```

> Change `YOUR-GCP-PROJECT`, `YOUR-REGION`, and Artifact Registry path in `helm/hello-app/values.yaml`.
