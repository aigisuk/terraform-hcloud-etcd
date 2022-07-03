variable "ssh_public_key" {
  type        = string
  description = "SSH Public Key"
}

variable "ssh_public_key_name" {
  type        = string
  description = "SSH Public Key Name"
  default     = "default"
}

variable "location" {
  type        = string
  description = "Location in which to provision the cluster. Default is nbg1 (Nuremberg, Germany)"
  default     = "nbg1"
  validation {
    condition     = length(regexall("^nbg1|fsn1|hel1|ash$", var.location)) > 0
    error_message = "Invalid location. Valid locations include nbg1 (default), fsn1, hel2, ash."
  }
}

variable "etcd_version" {
  type        = string
  description = "Version of etcd to install"
  default     = "3.5.4"
}

variable "node_count" {
  type        = string
  description = "Number of etcd member nodes to provision"
  default     = 3
}

variable "etcd_network_range" {
  type        = string
  description = "Range of IP addresses for the network in CIDR notation. Must be one of the private ipv4 ranges of RFC1918"
  default     = "10.0.0.0/8"
}