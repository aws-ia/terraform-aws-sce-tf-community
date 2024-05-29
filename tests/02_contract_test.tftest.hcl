variables {
  s3_force_destroy = true
}

run "setup_sce_community" {
  command = apply
}

run "sqs_contract_test" {
  command = apply

  assert {
    condition     = aws_lambda_event_source_mapping.sce_provision_queue.event_source_arn == module.core.sqs_provision_queue_arn
    error_message = "The provisioning lambda is not mapped to the correct provisioning SQS queue"
  }

  assert {
    condition     = aws_lambda_event_source_mapping.sce_update_queue.event_source_arn == module.core.sqs_update_queue_arn
    error_message = "The provisioning lambda is not mapped to the correct update SQS queue"
  }

  assert {
    condition     = aws_lambda_event_source_mapping.sce_terminate_queue.event_source_arn == module.core.sqs_termination_queue_arn
    error_message = "The provisioning lambda is not mapped to the correct terminate SQS queue"
  }
}

run "setup_sample_product" {
  command = apply

  module {
    source = "./tests/setup/example-product"
  } 

  variables {
    parameter_parser_role_arn     = run.setup_sce_community.sce_parameter_parser_role_arn
    terraform_execution_role_arn  = run.setup_sce_community.terraform_execution_role
  }
}

run "provision_product" {
  command = apply

  module {
    source = "./tests/setup/provision-product"
  } 

  variables {
    sample_product_id = run.setup_sample_product.sample_product_id
  }

  assert {
    condition     = output.sample_product_provisioning_status == "AVAILABLE"
    error_message = "The provisioned product state is not equal AVAILABLE"
  }
}

run "update_product" {
  command = apply

  module {
    source = "./tests/setup/provision-product"
  } 

  variables {
    sample_product_id = run.setup_sample_product.sample_product_id
    trigger_update    = true
  }

  assert {
    condition     = output.sample_product_provisioning_status == "AVAILABLE"
    error_message = "The provisioned product state is not equal AVAILABLE"
  }
}