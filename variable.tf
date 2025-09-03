variable "my-instance-type" {
  description = "The instance type to use for the EC2 instance"
  type        = string
  default     = "t2.micro"
}
variable "client-name" {
  description = "The name of the client"
  type        = string
  default     = "default-client"
}
