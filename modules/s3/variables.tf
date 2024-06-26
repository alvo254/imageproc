variable "project" {
  default = "imgproc"
}
variable "env" {
  default = "dev"
}


variable "unsized_img_bucket" {
  description = "This bucket holds uploaded images to be resized"
  default = "imgproc-unsized-bucket"
}

variable "sized_img_bucket" {
  description = "This bucket hold images that were resized after lambda trigger"
  default = "imgproc-sized"
}