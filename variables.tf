
variable "linux_web_app_name" {
  description = "The name of your web application."
  type        = string
}

variable "mssqlserver_name" {
  description = "The name of your MSSQL Server."
  type        = string
}

variable "mssqldb_name" {
  description = "The name of the MSSQL Database."
  type        = string
}

variable "firewall_rule_name" {
  description = "The name of the firewall rule to use."
  type        = string
}

variable "admin_login" {
  description = "The username to use for logging to MSSQL Database"
  type        = string
}

variable "admin_pass" {
  description = "The password to use for logging to MSSQL Database"
  type        = string
}


variable "github-repo-url" {
  description = "The URL of your GitHub Repository"
  type        = string
}

variable "github-repo-main-branch" {
  description = "The default branch in your GitHub Repository"
  type        = string
}