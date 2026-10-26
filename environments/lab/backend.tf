# -----------------------------------------------------------------------------
# backend.tf
# Remote state with S3 native locking. Placeholder bucket until a real account.
# -----------------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket       = "REPLACE-ME-tfstate-bucket-hybrid"
    key          = "hybrid/lab/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
