variable "sql_injection" {
  type    = bool
  default = "false"
}

variable "cross_site_scripting" {
  type    = bool
  default = "false"
}
variable "site_upload" {
  type    = bool
  default = "true"
}

variable "ip_blacklist" {
  type = object({
    enable = bool
    list   = list(string)
  })
  default = {
    enable = "false"
    list   = []
  }
}
