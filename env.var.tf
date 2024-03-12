variable "AWS_ACCESS_KEY" {
  type        = string
  description = "Set the AWS Access Key"
  default     = null
}

variable "AWS_SECRET_KEY" {
  type        = string
  description = "Set the AWS Secret Key"
  default     = null
}

variable "AWS_REGION" {
  type        = string
  description = "Set the AWS Region"
  default     = "us-east-1"
}

variable "CIDR_BLOCK" {
  type    = string
  default = "10.10.0.0/20"
}

variable "AWS_AZ_ONE" {
  type        = string
  description = "Set the AWS AZ"
  default     = "us-east-1a"
}

variable "AWS_AZ_TWO" {
  type        = string
  description = "Set the AWS AZ"
  default     = "us-east-1b"
}

variable "AWS_INSTANCE_TYPE" {
  type        = string
  description = "Set EC2 Instance Type"
  default     = "t3.medium"
}

variable "AWS_SSH_USER" {
  type        = string
  description = "AWS SSH user"
  default     = "ubuntu"
}

variable "DB_NAME" {
  type        = string
  description = "MySQL DB Name"
  default     = "user_db"
}

variable "DB_PORT" {
  type        = string
  description = "MySQL DB Port"
  default     = "3306"
}


variable "DB_USER" {
  type        = string
  description = "MySQL DB user"
  default     = "fluwd_admin"
}


variable "DB_PW" {
  type        = string
  description = "MySQL DB Password"
  default     = "Password123"
}

locals {
  current_timestamp = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
}
