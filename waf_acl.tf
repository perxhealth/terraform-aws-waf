resource "aws_wafv2_rule_group" "rule_group" {
  count       = var.enabled ? 1 : 0
  provider    = aws.us-east-1
  name        = "sql-xss-rule"
  description = "An rule blocking sql injection and xss"
  scope       = "CLOUDFRONT"
  capacity    = 500

  dynamic "rule" {
    for_each = var.sql_injection ? [var.sql_injection] : []
    content {
      name     = "SQL"
      priority = 0

      action {
        block {}
      }

      statement {
        sqli_match_statement {
          field_to_match {
            all_query_arguments {}
          }
          text_transformation {
            priority = 5
            type     = "URL_DECODE"
          }
          text_transformation {
            priority = 4
            type     = "HTML_ENTITY_DECODE"
          }
          text_transformation {
            priority = 3
            type     = "COMPRESS_WHITE_SPACE"
          }
            }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "sqli-statement"
        sampled_requests_enabled   = false
      }
    }
  }

  dynamic "rule" {
    for_each = var.cross_site_scripting ? [var.cross_site_scripting] : []
    content {
      name      = "XSS"
      priority  = 1
      action {
        block {}
      }
      statement {
        xss_match_statement {
          field_to_match {
            all_query_arguments {}
          }
          text_transformation {
            priority = 2
            type     = "NONE"
          }
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled  = true
        metric_name                 = "xss-statement"
        sampled_requests_enabled    = false
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "sql-xss-rule-group"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl" "waf_acl" {
  count       = var.enabled ? 1 : 0
  provider    = aws.us-east-1
  scope       = "CLOUDFRONT"
  name        = var.name

  default_action {
    allow {}
  }

  rule {
    name = "CloudFrontGlobal-sql-xss"
    priority = 0

    override_action {
      none {}
    }

    statement {
      rule_group_reference_statement {
        arn = aws_wafv2_rule_group.rule_group[count.index].arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled  = true
      metric_name                 = "CloudFront-sql-xss-rule"
      sampled_requests_enabled    = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled  = true
    metric_name                 = "CloudFrontGlobalWafWebAcl"
    sampled_requests_enabled    = true
  }
}
