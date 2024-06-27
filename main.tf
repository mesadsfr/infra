terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 0.13"
}

variable "SCW_ORGANIZATION_ID" {
  type      = string
  sensitive = true
}

variable "SCW_ACCESS_KEY" {
  type      = string
  sensitive = true
}

variable "SCW_SECRET_KEY" {
  type      = string
  sensitive = true
}

variable "SCW_REGION" {
  type      = string
  sensitive = true
}

variable "SCW_ZONE" {
  type      = string
  sensitive = true
}

variable "SCW_PROJECT_ID" {
  type      = string
  sensitive = true

}

provider "scaleway" {
  organization_id = var.SCW_ORGANIZATION_ID
  access_key      = var.SCW_ACCESS_KEY
  secret_key      = var.SCW_SECRET_KEY
  region          = var.SCW_REGION
  zone            = var.SCW_ZONE
  project_id      = var.SCW_PROJECT_ID
}

### IAM users are created manually from the console. Retrieve them. ###
variable "ADMIN_USERS" {
  type = list(string)
}

variable "BILLING_USERS" {
  type = list(string)
}

locals {
  admin_users   = { for email in var.ADMIN_USERS : email => {} }
  billing_users = { for email in var.BILLING_USERS : email => {} }
}

data "scaleway_iam_user" "admin-users" {
  for_each = local.admin_users
  email    = each.key
}

data "scaleway_iam_user" "billing-users" {
  for_each = local.billing_users
  email    = each.key
}

### IAM Applications, policies and API keys ###

# Push jobs docker images from CI
resource "scaleway_iam_application" "infra-ci" {
  name        = "infra-ci"
  description = "Token used by the CI to push docker images to the registry"
}

resource "scaleway_iam_policy" "push-docker-images-to-registry" {
  name           = "Push images to container registry"
  application_id = scaleway_iam_application.infra-ci.id

  rule {
    organization_id = "0292762e-99e9-4ac6-a64a-17337d698723"
    permission_set_names = [
      "ContainerRegistryFullAccess",
    ]
  }
}

resource "scaleway_iam_api_key" "infra-ci" {
  application_id = scaleway_iam_application.infra-ci.id
  description    = "Store infra images in the container registry. Used by https://github.com/mesadsfr/infra"
}

# Store backups
resource "scaleway_iam_application" "s3-store-backups" {
  name        = "s3-store-backups"
  description = "Used by https://github.com/mesadsfr/infra to store db and s3 backups to S3"
}

resource "scaleway_iam_policy" "store_backups" {
  name           = "Store backups"
  application_id = scaleway_iam_application.s3-store-backups.id

  rule {
    organization_id = var.SCW_ORGANIZATION_ID
    permission_set_names = [
      "ObjectStorageBucketsRead",
      "ObjectStorageObjectsRead",
      "ObjectStorageObjectsWrite",
    ]
  }
}

resource "scaleway_iam_api_key" "s3-store-backups" {
  application_id = scaleway_iam_application.s3-store-backups.id
}

# Terraform
resource "scaleway_iam_application" "terraform" {
  name        = "terraform"
  description = "Generate scaleway resources with terraform"
}

resource "scaleway_iam_api_key" "terraform" {
  application_id = scaleway_iam_application.terraform.id
  description    = "Key to setup and update the Scaleway infrastructure for mesads"
}

### IAM groups and memberships ###
resource "scaleway_iam_group" "administrators" {
  name                = "Administrators"
  external_membership = false
  application_ids = [
    scaleway_iam_application.terraform.id,
  ]
  user_ids = [
    for user in data.scaleway_iam_user.admin-users : user.id
  ]
}

resource "scaleway_iam_group" "billing-administrators" {
  name                = "Billing Administrators"
  external_membership = false
  user_ids = [
    for user in data.scaleway_iam_user.billing-users : user.id
  ]
}


### S3 Bucket ###

resource "scaleway_object_bucket" "mesads-backups" {
  name          = "mesads-backups"
  region        = "fr-par"
  force_destroy = false

  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 0
    enabled                                = true
    id                                     = "remove-old-files"
    prefix                                 = "database/"

    expiration {
      days = 30
    }
  }
}

resource "scaleway_object_bucket_acl" "mesads-backups" {
  bucket = scaleway_object_bucket.mesads-backups.id
  acl    = "private"
}

### Container registry ###

resource "scaleway_registry_namespace" "mesads" {
  name      = "mesads"
  is_public = false
}


### Jobs ###
variable "AWS_ACCESS_KEY_ID" {
  type      = string
  sensitive = true
}

variable "AWS_SECRET_ACCESS_KEY" {
  type      = string
  sensitive = true
}

variable "PGDATABASE" {
  type      = string
  sensitive = true
}

variable "PGHOST" {
  type      = string
  sensitive = true
}

variable "PGPASSWORD" {
  type      = string
  sensitive = true
}

variable "PGPORT" {
  type      = string
  sensitive = true
}

variable "PGUSER" {
  type      = string
  sensitive = true
}

variable "S3_PATH" {
  type      = string
  sensitive = true
}

resource "scaleway_job_definition" "backup-db" {
  name         = "mesads-backup-db"
  cpu_limit    = 1120
  memory_limit = 2048
  image_uri    = "rg.fr-par.scw.cloud/mesads/backup-db:latest"
  description  = "Backup MesADS PostgreSQL database"

  env = {
    AWS_ACCESS_KEY_ID     = var.AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY = var.AWS_SECRET_ACCESS_KEY
    PGDATABASE            = var.PGDATABASE
    PGHOST                = var.PGHOST
    PGPASSWORD            = var.PGPASSWORD
    PGPORT                = var.PGPORT
    PGUSER                = var.PGUSER
    S3_PATH               = var.S3_PATH
  }

  cron {
    schedule = "0 1,13 * * *"
    timezone = "Europe/Paris"
  }
}

variable "CC_ACCESS_KEY_ID" {
  type      = string
  sensitive = true
}

variable "CC_SECRET_ACCESS_KEY" {
  type      = string
  sensitive = true
}

variable "SCW_ACCESS_KEY_ID" {
  type      = string
  sensitive = true
}

variable "SCW_SECRET_ACCESS_KEY" {
  type      = string
  sensitive = true
}

resource "scaleway_job_definition" "backup-s3" {
  name         = "mesads-backup-s3"
  cpu_limit    = 280
  memory_limit = 512
  description  = "Backup MesADS S3 bucket"
  image_uri    = "rg.fr-par.scw.cloud/mesads/backup-s3:latest"

  env = {
    CC_ACCESS_KEY_ID      = var.CC_ACCESS_KEY_ID
    CC_SECRET_ACCESS_KEY  = var.CC_SECRET_ACCESS_KEY
    SCW_ACCESS_KEY_ID     = var.SCW_ACCESS_KEY_ID
    SCW_SECRET_ACCESS_KEY = var.SCW_SECRET_ACCESS_KEY
  }

  cron {
    schedule = "0 2,14 * * *"
    timezone = "Europe/Paris"
  }
}
