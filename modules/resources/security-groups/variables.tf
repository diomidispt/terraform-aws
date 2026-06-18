variable "vpc_id" {
  description = "(Required) The VPC ID"
  type        = string
}

variable "security_groups" {
  description = "(Required) A map of security groups configuration objects"
  type = map(object({
    name        = optional(string)
    description = optional(string)
    ingress = optional(list(object(
      {
        from_port                = number
        to_port                  = number
        protocol                 = string
        cidr_blocks              = optional(list(string))
        ipv6_cidr_blocks         = optional(list(string))
        prefix_list_ids          = optional(list(string))
        source_security_group_id = optional(string)
        self                     = optional(bool)
        description              = optional(string)
      }
    )))
    egress = optional(list(object(
      {
        from_port                = number
        to_port                  = number
        protocol                 = optional(string)
        cidr_blocks              = optional(list(string))
        ipv6_cidr_blocks         = optional(list(string))
        prefix_list_ids          = optional(list(string))
        source_security_group_id = optional(string)
        self                     = optional(bool)
        description              = optional(string)
      }
    )))
  }))

}

# This is kept here in case we want to set defaults in the future
locals {

  security_group_rules_ingress = flatten(
    [
      for security_group_key, security_group in var.security_groups : [
        for ingress_rule in security_group.ingress : {
          security_group_id        = aws_security_group.this[security_group_key].id
          from_port                = ingress_rule.from_port
          to_port                  = ingress_rule.to_port
          protocol                 = ingress_rule.protocol
          cidr_blocks              = ingress_rule.cidr_blocks
          ipv6_cidr_blocks         = ingress_rule.ipv6_cidr_blocks
          prefix_list_ids          = ingress_rule.prefix_list_ids
          source_security_group_id = ingress_rule.source_security_group_id
          self                     = ingress_rule.self
          description              = ingress_rule.description
        }
      ]
    ]
  )

  security_group_rules_egress = flatten(
    [
      for security_group_key, security_group in var.security_groups : [
        for egress_rule in security_group.egress : {
          security_group_id        = aws_security_group.this[security_group_key].id
          from_port                = egress_rule.from_port
          to_port                  = egress_rule.to_port
          protocol                 = egress_rule.protocol
          cidr_blocks              = egress_rule.cidr_blocks
          ipv6_cidr_blocks         = egress_rule.ipv6_cidr_blocks
          prefix_list_ids          = egress_rule.prefix_list_ids
          source_security_group_id = egress_rule.source_security_group_id
          self                     = egress_rule.self
          description              = egress_rule.description
        }
      ]
    ]
  )
}
