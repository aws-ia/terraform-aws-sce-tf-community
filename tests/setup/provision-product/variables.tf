variable "sample_product_id" {
  type        = string
  description = "Target product id to be provisioned"
}

variable "trigger_update" {
  type        = bool
  default     = false
  description = "Trigger update for the product"
}