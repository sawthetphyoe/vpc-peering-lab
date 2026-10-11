# Statement
resource "aws_instance" "statement" {
  ami           = data.aws_ami.fake_service.id
  instance_type = var.service_instance_type

  subnet_id                   = aws_subnet.statement.id
  vpc_security_group_ids      = [aws_security_group.statement.id]
  associate_public_ip_address = false

  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail

    cat > /etc/fake-service.env <<'ENV'
    NAME=statement
    LISTEN_ADDR=0.0.0.0:${var.service_port}
    UPSTREAM_URIS=
    ENV

    chmod 0644 /etc/fake-service.env
    systemctl enable --now fake-service
  EOF

  tags = {
    Name = "statement"
  }
}

# Account
resource "aws_instance" "account" {
  ami           = data.aws_ami.fake_service.id
  instance_type = var.service_instance_type

  subnet_id                   = aws_subnet.account.id
  vpc_security_group_ids      = [aws_security_group.account.id]
  associate_public_ip_address = false

  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail

    cat > /etc/fake-service.env <<'ENV'
    NAME=account
    LISTEN_ADDR=0.0.0.0:${var.service_port}
    UPSTREAM_URIS=http://${aws_instance.statement.private_ip}:${var.service_port}
    ENV

    chmod 0644 /etc/fake-service.env
    systemctl enable --now fake-service
  EOF

  tags = {
    Name = "account"
  }
}

# Customer Profile
resource "aws_instance" "customer_profile" {
  ami           = data.aws_ami.fake_service.id
  instance_type = var.service_instance_type

  subnet_id                   = aws_subnet.customer_profile.id
  vpc_security_group_ids      = [aws_security_group.customer_profile.id]
  associate_public_ip_address = true

  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail

    cat > /etc/fake-service.env <<'ENV'
    NAME=customer-profile
    LISTEN_ADDR=0.0.0.0:${var.service_port}
    UPSTREAM_URIS=http://${aws_instance.account.private_ip}:${var.service_port}
    ENV

    chmod 0644 /etc/fake-service.env
    systemctl enable --now fake-service
  EOF

  tags = {
    Name = "customer-profile"
  }
}
