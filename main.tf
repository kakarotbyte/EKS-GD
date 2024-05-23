module scenario_two {
    source = "./modules/Two"
}
module scenario_one {
    source = "./modules/one"
}


resource "aws_guardduty_detector" "example" {
  enable = true
}

resource "aws_guardduty_detector_feature" "eks_runtime_monitoring" {
  detector_id = aws_guardduty_detector.example.id
  name        = "EKS_RUNTIME_MONITORING"
  status      = "ENABLED"

  additional_configuration {
    name   = "EKS_ADDON_MANAGEMENT"
    status = "ENABLED"
  }
}

#resource "aws_guardduty_detector_feature" "eks_audit_logs" {
#  detector_id = aws_guardduty_detector.example.id
#  name        = "EKS_AUDIT_LOGS"
#  status      = "ENABLED"
#}