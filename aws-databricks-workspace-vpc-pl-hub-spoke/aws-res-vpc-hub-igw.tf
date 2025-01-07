// Internet gateway in VPC Hub
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_hub.id
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-igw"
  })
  depends_on = [aws_vpc.vpc_hub]
}
