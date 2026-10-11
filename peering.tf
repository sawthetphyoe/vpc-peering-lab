resource "aws_vpc_peering_connection" "customer_profile_account" {
  vpc_id      = aws_vpc.customer-profile-vpc.id
  peer_vpc_id = aws_vpc.account.id
  auto_accept = true

  tags = {
    Name = "customer-profile-account"
  }
}

resource "aws_vpc_peering_connection" "account_statement" {
  vpc_id      = aws_vpc.account.id
  peer_vpc_id = aws_vpc.statement.id
  auto_accept = true

  tags = {
    Name = "account-statement"
  }
}