output "id" {
  value       = var.enabled ? aws_wafv2_web_acl.waf_acl[0].id : null
  description = "WAF ACL arn to be consumed"
}
