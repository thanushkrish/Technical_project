
variable "region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "ap-south-1"   # <--- change to your preferred region
}



variable "bucket_name" {
  description = "S3 bucket name (must be globally unique)"
  type        = string
  default     = "my-jumpalumpabucket" # <--- change to something globally unique
}

# --- Networking / sizing (you can tweak) ---
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "availability_zone" {
  type    = string
  default = "" # optional; leave empty to let AWS pick
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
