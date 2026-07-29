# to pass this to other module to us for HTTP request 
output "certificate_arn" { 
description = "The digital id made by the acm" 
value = aws_acm_certificate.main.arn
}