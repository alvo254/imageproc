variable "cidr_block" {
  default = "10.0.0.0/20"
}

variable "project" {
  default = "imgproc"
}

variable "env" {
  default = "Dev"
}

variable "public_subnet" {
  default = "10.0.0.0/21"
}

variable "private_subnet" {
  default = "10.0.8.0/21"
}

