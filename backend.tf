terraform {
  backend "gcs" {
    bucket  = "dd-cp-tf-state"
  }
}
