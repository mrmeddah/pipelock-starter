terraform {
  backend "local" {
    path = "terraform.tfstate"  #Locally (khseni nbdlha aprés man'cree S3 bucket, after that ghndire migration mn local l S3)
  }
}
