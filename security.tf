
resource "aws_security_group" "customer_profile" {
  name        = "customer-profile"
  description = "Customer profile service"
  vpc_id      = aws_vpc.customer-profile-vpc.id
}

resource "aws_security_group" "account" {
  name        = "account"
  description = "Account service"
  vpc_id      = aws_vpc.account.id
}

resource "aws_security_group" "statement" {
  name        = "statement"
  description = "Statement service"
  vpc_id      = aws_vpc.statement.id
}

resource "aws_vpc_security_group_ingress_rule" "customer_profile_public" {
  security_group_id = aws_security_group.customer_profile.id
  cidr_ipv4         = var.customer_profile_ingress_cidr
  ip_protocol       = "tcp"
  from_port         = var.service_port
  to_port           = var.service_port
}

resource "aws_vpc_security_group_ingress_rule" "account_from_customer_profile" {
  security_group_id            = aws_security_group.account.id
  referenced_security_group_id = aws_security_group.customer_profile.id
  ip_protocol                  = "tcp"
  from_port                    = var.service_port
  to_port                      = var.service_port

  depends_on = [aws_vpc_peering_connection.customer_profile_account]
}

resource "aws_vpc_security_group_ingress_rule" "statement_from_account" {
  security_group_id            = aws_security_group.statement.id
  referenced_security_group_id = aws_security_group.account.id
  ip_protocol                  = "tcp"
  from_port                    = var.service_port
  to_port                      = var.service_port

  depends_on = [aws_vpc_peering_connection.account_statement]
}

resource "aws_vpc_security_group_egress_rule" "customer_profile_to_account" {
  security_group_id            = aws_security_group.customer_profile.id
  referenced_security_group_id = aws_security_group.account.id
  ip_protocol                  = "tcp"
  from_port                    = var.service_port
  to_port                      = var.service_port

  depends_on = [aws_vpc_peering_connection.customer_profile_account]
}

resource "aws_vpc_security_group_egress_rule" "account_to_statement" {
  security_group_id            = aws_security_group.account.id
  referenced_security_group_id = aws_security_group.statement.id
  ip_protocol                  = "tcp"
  from_port                    = var.service_port
  to_port                      = var.service_port

  depends_on = [aws_vpc_peering_connection.account_statement]
}
