output "vpc_id" {
  value = aws_vpc.default.id
}

output "public_subnets" {
  value = [aws_subnet.public_0.id, aws_subnet.public_1.id]
}

output "private_subnets" {
  value = [aws_subnet.private_0.id, aws_subnet.private_1.id]
}

output "vpc_cidr_block" {
  value = aws_vpc.default.cidr_block
}
