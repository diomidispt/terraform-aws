resource "aws_security_group" "this" {
  for_each    = var.security_groups
  vpc_id      = var.vpc_id
  name        = each.value.name != null ? each.value.name : each.key
  description = each.value.description
  tags = tomap({
    "Name" = each.value.name != null ? each.value.name : each.key
  })

}

resource "aws_security_group_rule" "ingress" {
  count                    = length(local.security_group_rules_ingress)
  type                     = "ingress"
  security_group_id        = local.security_group_rules_ingress[count.index].security_group_id
  from_port                = local.security_group_rules_ingress[count.index].from_port
  to_port                  = local.security_group_rules_ingress[count.index].to_port
  protocol                 = local.security_group_rules_ingress[count.index].protocol
  cidr_blocks              = local.security_group_rules_ingress[count.index].cidr_blocks
  ipv6_cidr_blocks         = local.security_group_rules_ingress[count.index].ipv6_cidr_blocks
  prefix_list_ids          = local.security_group_rules_ingress[count.index].prefix_list_ids
  source_security_group_id = local.security_group_rules_ingress[count.index].source_security_group_id
  self                     = local.security_group_rules_ingress[count.index].self
  description              = local.security_group_rules_ingress[count.index].description
}

resource "aws_security_group_rule" "egress" {
  count                    = length(local.security_group_rules_egress)
  type                     = "egress"
  security_group_id        = local.security_group_rules_egress[count.index].security_group_id
  from_port                = local.security_group_rules_egress[count.index].from_port
  to_port                  = local.security_group_rules_egress[count.index].to_port
  protocol                 = local.security_group_rules_egress[count.index].protocol
  cidr_blocks              = local.security_group_rules_egress[count.index].cidr_blocks
  ipv6_cidr_blocks         = local.security_group_rules_egress[count.index].ipv6_cidr_blocks
  prefix_list_ids          = local.security_group_rules_egress[count.index].prefix_list_ids
  source_security_group_id = local.security_group_rules_egress[count.index].source_security_group_id
  self                     = local.security_group_rules_egress[count.index].self
  description              = local.security_group_rules_egress[count.index].description
}