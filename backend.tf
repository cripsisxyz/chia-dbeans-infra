terraform {
  backend "gcs" {
    bucket  = "dbeans-cp-tf-state"
  }
}
