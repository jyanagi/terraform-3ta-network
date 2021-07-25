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

# VLAN Segment Names and Details. Required for external interfaces.
variable "segment_fa_vlan_name" {
  default = "nsx-vlan-2811-seg"
}
  
variable "segment_fa_vlan_id" {
  default = "2811"
}

variable "segment_fb_vlan_name" {
  default = "nsx-vlan-2812-seg"
}
  
variable "segment_fb_vlan_id" {
  default = "2812"
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

variable "uplink_en1_fb_ip" {
  default = "10.28.12.1/24"
}

variable "uplink_en2_fb_ip" {
  default = "10.28.12.2/24"
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

variable "router_b_remote_as" {
  default = "65000"
}

variable "hold_down_time" {
  default = "12"
}

variable "keep_alive_time" {
  default = "4"
}

# Overlay Segment Names and Details
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

#Web Segment DHCP IP Address Range
variable "segment_web_dhcp_range" {
  default = "10.16.80.10-10.16.80.100"
}

#Web Segment DHCP Server (Gateway)
variable "segment_web_dhcp_server_address" {
  default = "10.16.80.254/24"
}

#Web Segment DHCP DNS Server
variable "segment_web_dhcp_dns_server" {
  default = "172.16.11.50"
}

variable "segment_app_cidr" {
  default = "10.16.81.253/24"
}

#App Segment DHCP IP Address Range
variable "segment_app_dhcp_range" {
  default = "10.16.81.10-10.16.81.100"
}

#App Segment DHCP Server (Gateway)
variable "segment_app_dhcp_server_address" {
  default = "10.16.81.254/24"
}

#App Segment DHCP DNS Server
variable "segment_app_dhcp_dns_server" {
  default = "172.16.11.50"
}

variable "segment_db_cidr" {
  default = "10.16.82.253/24"
}

#DB Segment DHCP IP Address Range
variable "segment_db_dhcp_range" {
  default = "10.16.82.10-10.16.82.100"
}

#DB Segment DHCP Server (Gateway)
variable "segment_db_dhcp_server_address" {
  default = "10.16.82.254/24"
}

#DB Segment DHCP DNS Server
variable "segment_db_dhcp_dns_server" {
  default = "172.16.11.50"
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

# Replace IP address if using a load balancer (VIP) for Web Servers
variable "web_vip_ip" {
  default = "10.16.0.4"
}

# Replace IP address if using a load balancer (VIP) for App Servers
variable "app_vip_ip" {
  default = "10.16.0.3"
}

# Replace CIDR address if using NSX Advanced Load Balancer service engines (SE-Data)
variable "avi_se_data_cidr" {
  default = "10.16.21.0/24"
}
