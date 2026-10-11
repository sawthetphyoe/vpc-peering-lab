data "aws_ami" "fake_service" {
  owners = ["self"]

  filter {
    name   = "image-id"
    values = [var.service_ami_id]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
