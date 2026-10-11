resource "aws_subnet" "customer_profile" {
  vpc_id                  = aws_vpc.customer-profile-vpc.id
  cidr_block              = var.subnet_cidrs.customer_profile
  map_public_ip_on_launch = true

  tags = {
    Name = "customer-profile-subnet"
  }
}




resource "aws_subnet" "account" {
  vpc_id                  = aws_vpc.account.id
  cidr_block              = var.subnet_cidrs.account
  map_public_ip_on_launch = false

  tags = {
    Name = "account-subnet"
  }
}


resource "aws_subnet" "statement" {
  vpc_id                  = aws_vpc.statement.id
  cidr_block              = var.subnet_cidrs.statement
  map_public_ip_on_launch = false

  tags = {
    Name = "statement-subnet"
  }
}
