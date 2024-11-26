output "cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "node_group_name" {
  value = aws_eks_node_group.eks_nodes.node_group_name
}

output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}

output "public_subnets" {
  value = aws_subnet.eks_public_subnets[*].id
}

#output "private_subnets" {
  #value = aws_subnet.eks_private_subnets[*].id
#}
