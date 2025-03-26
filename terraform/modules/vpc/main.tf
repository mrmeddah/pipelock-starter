# Main VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "metabase-vpc"
  }
}

# Public Subnets (NAT)
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 10}.0/24"  # 10.0.10.0/24, 10.0.11.0/24
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index) #Hena dert 2 ela wed High Availability
  map_public_ip_on_launch = true  
  tags = {
    Name = "metabase-public-${count.index}"
  }
}

# Private Subnets (ECS/RDS)
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"  # 10.0.0.0/24, 10.0.1.0/24
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  tags = {
    Name = "metabase-private-${count.index}"
  }
}

# Internet Gateway (Public)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "metabase-igw"
  }
}

# Elastic IP Dyal NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "metabase-nat-eip"
  }
}

# NAT Gateway (Hna Private Subnets y9dro yt'connectaw b l'internet)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # (Hna kikon first IP add)
  tags = {
    Name = "metabase-nat"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "metabase-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "metabase-private-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# VPC Flow Logs (Hna 3tite lCloudWatch perm bech ychof logs)
resource "aws_flow_log" "vpc" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name = "metabase-vpc-flow-logs"
}

# Hna 3tite L'IAM Role Policy
resource "aws_iam_role" "vpc_flow_logs" {
  name = "metabase-vpc-flow-logs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "metabase-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "*"
    }]
  })
}

# Ba9i khsni nzid Layer-3 firewall rules aprés (Network ACL's)
# Aussi khseni nzid Security Groups