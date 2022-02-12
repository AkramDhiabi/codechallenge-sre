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