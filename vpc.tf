resource "aws_vpc" "customer-profile-vpc" {
  cidr_block = var.vpc_cidrs.customer_profile
}

resource "aws_vpc" "account" {
  cidr_block = var.vpc_cidrs.account
}

resource "aws_vpc" "statement" {
  cidr_block = var.vpc_cidrs.statement
}
