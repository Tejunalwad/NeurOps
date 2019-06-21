# Internet VPC
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    enable_classiclink = "false"
    tags {
        Name = "main"
    }
}

# Subnets
resource "aws_subnet" "main-public" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-west-2a"

    tags {
        Name = "main-public"
    }
}

resource "aws_subnet" "main-private" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = "us-west-2a"

    tags {
        Name = "main-private"
    }
}

# Internet GW
resource "aws_internet_gateway" "main-gw" {
    vpc_id = "${aws_vpc.main.id}"

    tags {
        Name = "main"
    }
}

# nat gw
resource "aws_eip" "nat" {
  vpc      = true
}
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${aws_subnet.main-public.id}"
  depends_on = ["aws_internet_gateway.main-gw"]
}

# route tables
resource "aws_route_table" "main-public-rt" {
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.main-gw.id}"
    }

    tags {
        Name = "main-public-rt"
    }
}

#nat routing
resource "aws_route_table" "main-private-rt" {
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.nat-gw.id}"
    }

    tags {
        Name = "main-private-rt"
    }
}

# route associations public
resource "aws_route_table_association" "main-public-rt-a" {
    subnet_id = "${aws_subnet.main-public.id}"
    route_table_id = "${aws_route_table.main-public-rt.id}"
}

# nat association with private subnet
resource "aws_route_table_association" "main-private-rt-a" {
    subnet_id = "${aws_subnet.main-private.id}"
    route_table_id = "${aws_route_table.main-private-rt.id}"
}