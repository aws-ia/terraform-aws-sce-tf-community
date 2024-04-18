resource "aws_servicecatalog_provisioned_product" "example" {
  name                        = "example"
  product_id                  = var.sample_product_id
  provisioning_artifact_name  = "v1"

  dynamic "provisioning_parameters" {
    for_each = var.trigger_update ? [1] : [0]
    content {
      key   = var.trigger_update ? "random_string_length" : ""
      value = var.trigger_update ? "8" : ""
    }
  }
}

resource "time_sleep" "wait_for_provisioning_to_complete" {
  depends_on      = [aws_servicecatalog_provisioned_product.example]
  create_duration = "120s"
}