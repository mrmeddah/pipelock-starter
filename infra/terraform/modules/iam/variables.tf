variable "enable_s3_exports" {
  description = "Whether to grant S3 export permissions to Metabase"
  type        = bool
  default     = false
}

variable "github_repo" {
  description = "GitHub repository in format 'repo' for CI/CD OIDC"
  type        = string
  default     = "https://github.com/mrmeddah/pipelock-starter" 
}

variable "dockerhub_username" {
  description = "Docker Hub username"
  type        = string
  sensitive   = true
}

variable "dockerhub_password" {
  description = "Docker Hub password or PAT"
  type        = string
  sensitive   = true
}