resource "aws_vpc" "imgproc" {
  instance_tenancy = "default"
  cidr_block = var.cidr_block
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-${var.env}-vpc"
  }

}



data "aws_availability_zones" "available_zones" {}

resource "aws_subnet" "public_imgproc_subnet" {
    vpc_id = aws_vpc.imgproc.id
    cidr_block = var.public_subnet
    assign_ipv6_address_on_creation = true
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available_zones.names[0]
    ipv6_cidr_block                 = cidrsubnet(aws_vpc.imgproc.ipv6_cidr_block, 8, 2)

    tags = {
        Name = "${var.project}-${var.env}-pub-sub-IPV6-expriment"
  }
}

resource "aws_internet_gateway" "imgproc_igw" {
  vpc_id = aws_vpc.imgproc.id

     tags = {
        Name = "${var.project}-${var.env}-igw"
  }
}

resource "aws_route_table" "imgproc_rtb" {
  vpc_id = aws_vpc.imgproc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.imgproc_igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.imgproc_igw.id
  }

  tags = {
    Name = "${var.project}-${var.env}-public-rt"
  }

}

resource "aws_route_table_association" "pawsome" {
  route_table_id = aws_route_table.imgproc_rtb.id
  subnet_id = aws_subnet.public_imgproc_subnet.id
}
