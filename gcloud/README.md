1. Enable APIs
$PROJECT_ID = "My Project 10522"
$REGION="us-west1"

gcloud config set project $PROJECT_ID

gcloud services enable `
    cloudbuild.googleapis.com `
    run.googleapis.com `
    artifactregistry.googleapis.com `
    secretmanager.googleapis.com

2. Create Artifact Registry
gcloud artifacts repositories create containers `
    --repository-format=docker `
    --location=$REGION `
    --description="Container images"


Configure Docker:

gcloud auth configure-docker $REGION-docker.pkg.dev

3. Create Cloud Run Service Account
gcloud iam service-accounts create cloudrun-sa


Grant permissions:

$PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID `
  --format='value(projectNumber)')

gcloud projects add-iam-policy-binding $PROJECT_ID `
  --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" `
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID `
  --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" `
  --role="roles/artifactregistry.writer"

gcloud projects add-iam-policy-binding $PROJECT_ID `
  --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" `
  --role="roles/iam.serviceAccountUser"


These roles are required for Cloud Build to push images and deploy Cloud Run services.

4. Add Dockerfile

Example for an ASP.NET, Node, Python, or any container workload.

FROM nginx:alpine

COPY . /usr/share/nginx/html

5. Add cloudbuild.yaml

Put this in the root of the repo:

steps:
- name: 'gcr.io/cloud-builders/docker'
  args:
    - build
    - '-t'
    - '${_REGION}-docker.pkg.dev/$PROJECT_ID/containers/${_SERVICE}:$SHORT_SHA'
    - '.'

- name: 'gcr.io/cloud-builders/docker'
  args:
    - push
    - '${_REGION}-docker.pkg.dev/$PROJECT_ID/containers/${_SERVICE}:$SHORT_SHA'

- name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
  entrypoint: gcloud
  args:
    - run
    - deploy
    - '${_SERVICE}'
    - '--image=${_REGION}-docker.pkg.dev/$PROJECT_ID/containers/${_SERVICE}:$SHORT_SHA'
    - '--region=${_REGION}'
    - '--platform=managed'
    - '--allow-unauthenticated'

substitutions:
  _REGION: us-west1
  _SERVICE: mysite

6. Connect GitHub to Cloud Build

Authenticate GitHub:

gcloud builds connections create github github-conn `
    --region=$REGION


This will produce a URL that you authorize against GitHub.

Register repository:

gcloud builds repositories create myrepo `
    --remote-uri=https://github.com/<user>/<repo>.git `
    --connection=projects/$PROJECT_ID/locations/$REGION/connections/github-conn `
    --region=$REGION

7. Create Branch Trigger

Build only from main:

gcloud builds triggers create github `
    --name="main-deploy" `
    --repo-name="<repo>" `
    --repo-owner="<github-user>" `
    --branch-pattern="^main$" `
    --build-config="cloudbuild.yaml"


Or use:

--branch-pattern="^prod$"


or

--branch-pattern="^release/.*$"


for other workflows.

Cloud Run Settings for Low Cost

For a small site:

gcloud run deploy mysite `
    --image=$REGION-docker.pkg.dev/$PROJECT_ID/containers/mysite:latest `
    --region=$REGION `
    --allow-unauthenticated `
    --cpu=1 `
    --memory=512Mi `
    --min-instances=0 `
    --max-instances=2


The important part is:

min-instances=0


That allows scaling completely to zero when nobody is visiting.

Custom Domain

Cloud Run includes a Google URL automatically.

Example:
https://mysite-xxxxx-uc.a.run.app


Then map your own domain:

gcloud run domain-mappings create `
    --service=mysite `
    --domain=www.example.com `
    --region=$REGION


Google manages the certificate automatically.

Realistic Cost

For a hobby/personal site:

Cloud Build

Suppose:

20 deployments/month
2 minute builds

That's 40 build minutes/month, which is typically either free-tier covered or only a few cents depending on usage.

Artifact Registry

A few container images:

5 images
500 MB total storage

Artifact Registry includes a storage free tier of 0.5 GiB and then charges per GiB-month beyond that.

Cloud Run

Typical personal website:

a few hundred visitors/month
scale-to-zero enabled
512 MiB memory

Often ends up at $0-$2/month.

A lightly used blog, resume site, or personal app frequently stays entirely within free-tier usage.

Custom Domain

No additional Cloud Run charge.

SSL Certificate

Included.

Load Balancer

Not required.

Since you specifically said*"I don't want an ELB, just whatever is provided"*, Cloud Run is ideal. You can point your domain directly at Cloud Run's domain mapping and skip any external load balancer.

What I would do

For your use case:

GitHub → Cloud Build trigger on main
Artifact Registry stores images
Cloud Run deploys automatically
min-instances=0
512 MiB RAM
Custom domain mapped directly to Cloud Run

That's about the lowest-maintenance and lowest-cost GCP web hosting stack you can run today.
4:08 PM









    
      document
        .querySelector('.app-loading-screen')
        .addEventListener('dblclick', () => window.showDebugLog());
    

    
    
      window.startApp();
    
  

