# Variables
# NSX Manager
variable "nsx_manager" {
  default = "nsx.projectonestone.io"
}

# Username & Password for NSX-T Manager
variable "username" {
  default = "admin"
}

variable "password" {
  default = "VMware1!VMware1!"
}

# Transport Zones & MTU
variable "vlan_tz" {
  default = "nsx-vlan-transportzone"
}

variable "overlay_tz" {
  default = "nsx-overlay-transportzone"
}

variable "tier0_uplink_mtu" {
  default = "1500"
}

# Enter Edge Nodes Display Name. Required for external interfaces.
variable "edge_node_1" {
  default = "edge03a"
}
variable "edge_node_2" {
  default = "edge03b"
}

variable "edge_cluster" {
  default = "ProjectONEStone API Cluster"
}

# Tier0 Gateway Configuration
variable "tier0_local_as" {
  default = 65020
}

variable "uplink_en1_fa_ip" {
  default = "10.28.11.1/24"
}

variable "uplink_en2_fa_ip" {
  default = "10.28.11.2/24"
}

variable "router_a_ip" {
  default = "10.28.11.253"
}

variable "router_b_ip" {
  default = "10.28.12.253"
}

variable "router_a_remote_as" {
  default = "65000"
}

variable "hold_down_time" {
  default = "12"
}

variable "keep_alive_time" {
  default = "4"
}

# Segment Names and Details
variable "segment_web" {
  default = "TF-Segment-3TA-Web"
}

variable "segment_app" {
  default = "TF-Segment-3TA-App"
}

variable "segment_db" {
  default = "TF-Segment-3TA-DB"
}

variable "segment_web_cidr" {
  default = "10.16.80.253/24"
}

variable "segment_app_cidr" {
  default = "10.16.81.253/24"
}

variable "segment_db_cidr" {
  default = "10.16.82.253/24"
}

# Security Group names
variable "nsx_group_web" {
  default = "TF-3TA-Web"
}

variable "nsx_group_app" {
  default = "TF-3TA-App"
}

variable "nsx_group_db" {
  default = "TF-3TA-DB"
}

variable "nsx_group_web_vip" {
  default = "TF-3TA-WEB-VIP"
}

variable "nsx_group_app_vip" {
  default = "TF-3TA-APP-VIP"
}

variable "nsx_group_se_data" {
  default = "AVI-SE-DATA"
}
