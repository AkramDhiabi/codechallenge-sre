variable "project" {
  default = "Superb"
}

variable "contact" {
  default = "dhiabi.akram@gmail.com"
}

variable "auth_image" {
  description = "ECR Image for auth service"
}

variable "booking_image" {
  description = "ECR Image for booking service"
}

variable "graphql_image" {
  description = "ECR Image for graphql service"
}

variable "dns_zone_name" {
  description = "Domain name"
  default  = "private.filestage.io"
}