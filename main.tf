# Fetch available availability zones in the current region
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "eks-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "eks_public_subnets" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-public-subnet-${count.index + 1}"
  }
}

#resource "aws_subnet" "eks_private_subnets" {
#  count             = length(var.private_subnets)
#  vpc_id            = aws_vpc.eks_vpc.id
#  cidr_block        = element(var.private_subnets, count.index)
#  availability_zone = element(data.aws_availability_zones.available.names, count.index)

#  tags = {
#    Name = "eks-private-subnet-${count.index + 1}"
#  }
#}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-igw"
  }
}

resource "aws_route_table" "eks_public_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "eks-public-rt"
  }
}

resource "aws_route_table_association" "eks_public_rta" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.eks_public_subnets[count.index].id
  route_table_id = aws_route_table.eks_public_rt.id
}

# Security Group
resource "aws_security_group" "allow_ssh" {
  vpc_id = aws_vpc.eks_vpc.id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      description = "Allow SSH"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.SG_allow-ssh}"
  }
}

# EKS IAM Role for the Cluster
resource "aws_iam_role" "eks-cluster-role2" {
  name = var.eks_cluster_role.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "eks-cluster-role2"
  }
}

resource "aws_iam_role_policy_attachment" "eks-cluster-role2_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks-cluster-role2.arn

  vpc_config {
    subnet_ids = concat(
      aws_subnet.eks_public_subnets[*].id,
      #     aws_subnet.eks_private_subnets[*].id
    )
  }

  depends_on = [aws_iam_role_policy_attachment.eks-cluster-role2_policy_attachment]
}

# EKS IAM Role for Worker Nodes
resource "aws_iam_role" "eks-node-role" {
  name = var.eks-node-role.name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
  tags = {
    Name = "eks-node-role"
  }
}
# Attach policies to EKS Node Role
resource "aws_iam_role_policy_attachment" "eks_node_role_policy_attachment" {
  role       = aws_iam_role.eks-node-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}


resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment" {
  role       = aws_iam_role.eks-node-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ec2_container_registry_policy_attachment" {
  role       = aws_iam_role.eks-node-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# EKS Managed Node Group
resource "aws_eks_node_group" "eks-nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks-node-role.arn

  scaling_config {
    desired_size = var.node_count
    max_size     = var.node_count
    min_size     = var.node_count
  }
  #  scaling_config {
  #   desired_size = var.desired_capacity
  #  max_size     = var.max_size
  # min_size     = var.min_size
  #}


  instance_types = [var.instance_type]
  subnet_ids     = aws_subnet.eks_public_subnets[*].id

  depends_on = [aws_eks_cluster.eks]
}
