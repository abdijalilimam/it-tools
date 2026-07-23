#domain name with a lifecyle rule to create before destroy
#The *.${var.domain_name} is a wildcard it covers ALL subdomains including it-tools.abdijalil.com, www.abdijalil.com etc.
resource "aws_acm_certificate" "main" {
  domain_name       = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method = "DNS"
  tags = {
    Name = var.domain_name
  }
  lifecycle {
    create_before_destroy = true
  }
}

# this is for acm to wait for validation before moving on
resource "aws_acm_certificate_validation" "main" {
  certificate_arn = aws_acm_certificate.main.arn
}