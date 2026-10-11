# Customer Profile
resource "aws_internet_gateway" "customer_profile" {
  vpc_id = aws_vpc.customer-profile-vpc.id
}

resource "aws_route_table" "customer_profile" {
  vpc_id = aws_vpc.customer-profile-vpc.id
}

resource "aws_route" "customer_profile_internet" {
  route_table_id         = aws_route_table.customer_profile.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.customer_profile.id
}

resource "aws_route_table_association" "customer_profile" {
  subnet_id      = aws_subnet.customer_profile.id
  route_table_id = aws_route_table.customer_profile.id
}

# Account
resource "aws_route_table" "account" {
  vpc_id = aws_vpc.account.id
}

resource "aws_route_table_association" "account" {
  subnet_id      = aws_subnet.account.id
  route_table_id = aws_route_table.account.id
}

# Statement
resource "aws_route_table" "statement" {
  vpc_id = aws_vpc.statement.id
}

resource "aws_route_table_association" "statement" {
  subnet_id      = aws_subnet.statement.id
  route_table_id = aws_route_table.statement.id
}


# customer-profile -> account
resource "aws_route" "customer_profile_to_account" {
  route_table_id            = aws_route_table.customer_profile.id
  destination_cidr_block    = aws_vpc.account.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.customer_profile_account.id
}

# account -> customer-profile
resource "aws_route" "account_to_customer_profile" {
  route_table_id            = aws_route_table.account.id
  destination_cidr_block    = aws_vpc.customer-profile-vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.customer_profile_account.id
}

# account -> statement
resource "aws_route" "account_to_statement" {
  route_table_id            = aws_route_table.account.id
  destination_cidr_block    = aws_vpc.statement.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.account_statement.id
}

# statement -> account
resource "aws_route" "statement_to_account" {
  route_table_id            = aws_route_table.statement.id
  destination_cidr_block    = aws_vpc.account.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.account_statement.id
}