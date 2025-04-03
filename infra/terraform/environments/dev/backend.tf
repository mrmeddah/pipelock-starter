terraform {
  backend "local" {
    path = "terraform.tfstate"  #Locally (khseni nbdlha aprés man'cree S3 bucket, after that ghndire migration mn local l S3)
  }
}

# Hna ghadir backend l S3 bucket 

/* terraform {
    backend "S3" {
        bucket = "smia-dyal-bucket"
        key= "terraform.tfstate"
        region = "us-east-1"
        dynamodb_table = "terraform-state-locking" #preventing to apply 2 things at a time
        encrypt = true 

    }
} */
