module "vpc" {
  source                 = "../../resources/vpc"
  name                   = "${local.environment_name}-VPC"
  cidr_block             = var.vpc.cidr_block
  enable_dns_support     = true
  enable_dns_hostnames   = true
  enable_internet_access = true
}

module "subnets_public" {
  source = "../../resources/subnets"
  vpc_id = module.vpc.id
  subnets = {
    for k, v in local.azs :
    "${local.environment_name}-Subnet-Public-${upper(v["name_suffix"])}" => {
      cidr_block        = cidrsubnet(var.vpc.cidr_block, 4, k)
      availability_zone = v["name"]
    }
  }
}
module "subnets_private" {
  source = "../../resources/subnets"
  vpc_id = module.vpc.id
  subnets = {
    for k, v in local.azs :
    "${local.environment_name}-Subnet-Private-${upper(v["name_suffix"])}" => {
      cidr_block        = cidrsubnet(var.vpc.cidr_block, 2, k + 1)
      availability_zone = v["name"]
    }
  }
  tags = var.private_subnet_tags
}

module "route_tables" {
  source = "../../resources/route-tables"
  vpc_id = module.vpc.id
  route_tables = merge({
    for k, v in local.azs :
    "${local.environment_name}-RT-Public-${upper(v["name_suffix"])}" => {
      network_scope = "public"
      subnets = [
        module.subnets_public.subnets[
          "${local.environment_name}-Subnet-Public-${upper(v["name_suffix"])}"
        ].id
      ]
      routes = [
        {
          "destination_cidr_block" = "0.0.0.0/0"
          "internet_gateway_id"    = module.vpc.internet_gateway.id
        }
      ]
    }
    },
    {
      for k, v in local.azs :
      "${local.environment_name}-RT-Private-${upper(v["name_suffix"])}" => {
        network_scope = "private"
        subnets = [
          module.subnets_private.subnets[
            "${local.environment_name}-Subnet-Private-${upper(v["name_suffix"])}"
          ].id
        ]
        # Private subnets egress to the internet (e.g. ECR image pulls) via the single NAT gateway (~$32/month)
        routes = [
          {
            destination_cidr_block = "0.0.0.0/0"
            nat_gateway_id = module.nat_gateways.nat_gateways[
              "${local.environment_name}-NAT-${upper(local.azs[0]["name_suffix"])}"
            ].id
          }
        ]
      }
    }
  )
}

# NAT gateway — lets private subnets (ECS tasks, RDS) reach the internet, e.g. pull images from ECR (~$32/month)
# Single NAT in the first AZ, shared by all private route tables (cost-optimized; not HA across AZs).
module "nat_gateways" {
  source = "../../resources/nat-gateways"
  nat_gateways = {
    "${local.environment_name}-NAT-${upper(local.azs[0]["name_suffix"])}" = {
      subnet_id = module.subnets_public.subnets["${local.environment_name}-Subnet-Public-${upper(local.azs[0]["name_suffix"])}"].id
    }
  }
}