# NSX-T Manager Credentials
provider "nsxt" {
  host                  = var.nsx_manager
  username              = var.username
  password              = var.password
  allow_unverified_ssl  = true
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
  retry_on_status_codes = [429]
}

# Data Sources we need for reference later
data "nsxt_policy_transport_zone" "overlay_tz" {
  display_name = var.overlay_tz
}

data "nsxt_policy_transport_zone" "vlan_tz" {
  display_name = var.vlan_tz
}

data "nsxt_policy_edge_cluster" "edge_cluster" {
  display_name = var.edge_cluster
}

data "nsxt_policy_service" "http" {
  display_name = "HTTP"
}

data "nsxt_policy_service" "https" {
  display_name = "HTTPS"
}

data "nsxt_policy_service" "mysql" {
  display_name = "MySQL"
}

data "nsxt_policy_edge_node" "edge_node_1" {
  edge_cluster_path = data.nsxt_policy_edge_cluster.edge_cluster.path
  display_name      = var.edge_node_1
}

data "nsxt_policy_edge_node" "edge_node_2" {
  edge_cluster_path = data.nsxt_policy_edge_cluster.edge_cluster.path
  display_name      = var.edge_node_2
}


# Create NSX-T VLAN Segments
resource "nsxt_policy_vlan_segment" "nsx-vlan-2811-seg" {
  display_name        = "nsx-vlan-2811-seg"
  description         = "VLAN Segment created by Terraform"
  transport_zone_path = data.nsxt_policy_transport_zone.vlan_tz.path
  vlan_ids            = ["2811"]
}

# Create Tier-0 Gateway
resource "nsxt_policy_tier0_gateway" "tf-tier0-gw" {
  display_name         = "TF_Tier_0"
  description          = "Tier-0 provisioned by Terraform"
  failover_mode        = "NON_PREEMPTIVE"
  default_rule_logging = false
  enable_firewall      = false
  # force_whitelisting        = true
  ha_mode           = "ACTIVE_ACTIVE"
  edge_cluster_path = data.nsxt_policy_edge_cluster.edge_cluster.path

  bgp_config {
    ecmp            = true
    local_as_num    = var.tier0_local_as
    inter_sr_ibgp   = true
    multipath_relax = true
  }

  redistribution_config {
    enabled = true
    rule {
      name  = "t0-route-redistribution"
      types = ["TIER1_LB_VIP", "TIER1_CONNECTED", "TIER1_SERVICE_INTERFACE", "TIER1_NAT", "TIER1_LB_SNAT"]
    }
  }

}

# Create Tier-0 Gateway Uplink Interfaces

# Edge Node 1 - Fabric A - Router Port Configuration
resource "nsxt_policy_tier0_gateway_interface" "uplink_en1_fa" {
  display_name   = "uplink-en1-fa"
  description    = "Uplink Edge Node 1 - Fabric A"
  type           = "EXTERNAL"
  edge_node_path = data.nsxt_policy_edge_node.edge_node_1.path
  gateway_path   = nsxt_policy_tier0_gateway.tf-tier0-gw.path
  segment_path   = nsxt_policy_vlan_segment.nsx-vlan-2811-seg.path
  subnets        = [var.uplink_en1_fa_ip]
  mtu            = var.tier0_uplink_mtu
}

# Edge Node 2 - Fabric A - Router Port Configuration
resource "nsxt_policy_tier0_gateway_interface" "uplink_en2_fa" {
  display_name   = "uplink-en1-fa"
  description    = "Uplink Edge Node 2 - Fabric A"
  type           = "EXTERNAL"
  edge_node_path = data.nsxt_policy_edge_node.edge_node_2.path
  gateway_path   = nsxt_policy_tier0_gateway.tf-tier0-gw.path
  segment_path   = nsxt_policy_vlan_segment.nsx-vlan-2811-seg.path
  subnets        = [var.uplink_en2_fa_ip]
  mtu            = var.tier0_uplink_mtu
}

# Local definitions
locals {
  # Concatinate Uplink Source IP's for ToR-A Peering
  peer_a_source_addresses = concat(
    nsxt_policy_tier0_gateway_interface.uplink_en1_fa.ip_addresses,
    nsxt_policy_tier0_gateway_interface.uplink_en2_fa.ip_addresses
  )
}

# BGP Neighbor Configuration ToR-A
resource "nsxt_policy_bgp_neighbor" "router_a" {
  display_name     = "ToR-A"
  description      = "Terraform provisioned BGP Neighbor Configuration"
  bgp_path         = nsxt_policy_tier0_gateway.tf-tier0-gw.bgp_config.0.path
  neighbor_address = var.router_a_ip
  remote_as_num    = var.router_a_remote_as
  hold_down_time   = var.hold_down_time
  keep_alive_time  = var.keep_alive_time
}

# Create Tier-1 Gateway
resource "nsxt_policy_tier1_gateway" "tf-tier1-gw" {
  description               = "Tier-1 provisioned by Terraform"
  display_name              = "TF-Tier-1-01"
  nsx_id                    = "predefined_id"
  edge_cluster_path         = data.nsxt_policy_edge_cluster.edge_cluster.path
  failover_mode             = "NON_PREEMPTIVE"
  default_rule_logging      = "false"
  enable_firewall           = "true"
  enable_standby_relocation = "false"
  # force_whitelisting        = "false"
  tier0_path                = nsxt_policy_tier0_gateway.tf-tier0-gw.path
  route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED"]

  route_advertisement_rule {
    name                      = "Tier 1 Networks"
    action                    = "PERMIT"
    subnets                   = ["10.16.80.0/24", "10.16.81.0/24", "10.16.82.0/24"]
    prefix_operator           = "GE"
    route_advertisement_types = ["TIER1_CONNECTED"]
  }
}

# DHCP Server
resource "nsxt_policy_dhcp_server" "dhcp_server" {
  display_name      = "DHCP Server"
  description       = "Terraform provisioned DHCP Server Config"
  edge_cluster_path = data.nsxt_policy_edge_cluster.edge_cluster.path
  lease_time        = 86400
}

# Create NSX-T Overlay Segments
resource "nsxt_policy_segment" "tf_segment_web" {
  display_name        = var.segment_web
  description         = "Segment created by Terraform"
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path
  connectivity_path   = nsxt_policy_tier1_gateway.tf-tier1-gw.path
  dhcp_config_path    = nsxt_policy_dhcp_server.dhcp_server.path

  subnet {
    cidr        = var.segment_web_cidr
    dhcp_ranges = ["10.16.80.10-10.16.80.100"]

    dhcp_v4_config {
      server_address = "10.16.80.254/24"
      lease_time     = 86400
      dns_servers    = ["172.16.11.50"]
    }
  }
}

resource "nsxt_policy_segment" "tf_segment_app" {
  display_name        = var.segment_app
  description         = "Segment created by Terraform"
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path
  connectivity_path   = nsxt_policy_tier1_gateway.tf-tier1-gw.path
  dhcp_config_path    = nsxt_policy_dhcp_server.dhcp_server.path

  subnet {
    cidr        = var.segment_app_cidr
    dhcp_ranges = ["10.16.81.10-10.16.81.100"]

    dhcp_v4_config {
      server_address = "10.16.81.254/24"
      lease_time     = 86400
      dns_servers    = ["172.16.11.50"]
    }
  }
}

resource "nsxt_policy_segment" "tf_segment_db" {
  display_name        = var.segment_db
  description         = "Segment created by Terraform"
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path
  connectivity_path   = nsxt_policy_tier1_gateway.tf-tier1-gw.path
  dhcp_config_path    = nsxt_policy_dhcp_server.dhcp_server.path

  subnet {
    cidr        = var.segment_db_cidr
    dhcp_ranges = ["10.16.82.50-10.16.82.100"]

    dhcp_v4_config {
      server_address = "10.16.82.254/24"
      lease_time     = 86400
      dns_servers    = ["172.16.11.50"]
    }
  }
}

# Create Security Groups
resource "nsxt_policy_group" "web_servers" {
  display_name = var.nsx_group_web
  description  = "Terraform provisioned Group"

  criteria {
    condition {
      key         = "Tag"
      member_type = "VirtualMachine"
      operator    = "CONTAINS"
      value       = "Web"
    }
  }
}

resource "nsxt_policy_group" "app_servers" {
  display_name = var.nsx_group_app
  description  = "Terraform provisioned Group"

  criteria {
    condition {
      key         = "Tag"
      member_type = "VirtualMachine"
      operator    = "CONTAINS"
      value       = "App"
    }
  }
}

resource "nsxt_policy_group" "db_servers" {
  display_name = var.nsx_group_db
  description  = "Terraform provisioned Group"

  criteria {
    condition {
      key         = "Tag"
      member_type = "VirtualMachine"
      operator    = "CONTAINS"
      value       = "DB"
    }
  }
}

resource "nsxt_policy_group" "web_vip" {
  display_name = var.nsx_group_web_vip
  description  = "Terraform provisioned Group"

  criteria {
    ipaddress_expression {
      ip_addresses = ["10.16.0.4"]
    }
  }
}

resource "nsxt_policy_group" "app_vip" {
  display_name = var.nsx_group_app_vip
  description  = "Terraform provisioned Group"

  criteria {
    ipaddress_expression {
      ip_addresses = ["10.16.0.3"]
    }
  }
}

resource "nsxt_policy_group" "avi_se_data" {
  display_name = var.nsx_group_se_data
  description  = "Terraform provisioned Group"

  criteria {
    ipaddress_expression {
      ip_addresses = ["10.16.21.0/24"]
    }
  }
}

# Create Custom Services
resource "nsxt_policy_service" "service_tcp8080" {
  description  = "HTTPS service provisioned by Terraform"
  display_name = "TCP 8080"

  l4_port_set_entry {
    display_name      = "TCP8080"
    description       = "TCP port 8080 entry"
    protocol          = "TCP"
    destination_ports = ["8080"]
  }
}

# Create Security Policies

# DFW Infrastructure Category Rules
resource "nsxt_policy_security_policy" "Infrastructure" {
  display_name = "Infrastructure"
  description  = "Terraform provisioned Security Policy"
  category     = "Infrastructure"
  locked       = false
  stateful     = true
  tcp_strict   = false

  rule {
    display_name = "Allow DHCP"
    action       = "ALLOW"
    services     = ["/infra/services/DHCP-Server", "/infra/services/DHCP-Client"]
    logged       = false
    notes        = "Allow access to DHCP Server"
  }
}

# DFW Application Category Rules
resource "nsxt_policy_security_policy" "allow_3TA" {
  display_name = "TF 3-Tier-App"
  description  = "Terraform provisioned Security Policy"
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = false
  #scope        = [nsxt_policy_group.web_servers.path]

  rule {
    display_name       = "NSX ALB SE to Web Servers"
    source_groups      = [nsxt_policy_group.avi_se_data.path]
    destination_groups = [nsxt_policy_group.web_servers.path]
    action             = "ALLOW"
    services           = [data.nsxt_policy_service.https.path, data.nsxt_policy_service.http.path]
    logged             = true
    scope              = [nsxt_policy_group.web_servers.path]
  }

  rule {
    display_name       = "Web to App Servers"
    source_groups      = [nsxt_policy_group.web_servers.path, nsxt_policy_group.avi_se_data.path]
    destination_groups = [nsxt_policy_group.app_servers.path, nsxt_policy_group.app_vip.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_tcp8080.path]
    logged             = true
    scope              = [nsxt_policy_group.web_servers.path, nsxt_policy_group.app_servers.path]
  }

  rule {
    display_name       = "App to DB Servers"
    source_groups      = [nsxt_policy_group.app_servers.path, nsxt_policy_group.avi_se_data.path]
    destination_groups = [nsxt_policy_group.db_servers.path]
    action             = "ALLOW"
    services           = [data.nsxt_policy_service.mysql.path]
    logged             = true
    scope              = [nsxt_policy_group.app_servers.path, nsxt_policy_group.db_servers.path]
  }

  rule {
    display_name = "Any Deny"
    action       = "REJECT"
    logged       = false
    scope        = [nsxt_policy_group.app_servers.path, nsxt_policy_group.db_servers.path, nsxt_policy_group.web_servers.path]
  }
}
