aws_Access_key  = "xxxxxxxxx"
aws_Secrete_key = "xxxxxxxxxxxxx"
region          = "us-east-1"
cluster_name    = "my-eks-cluster"
node_group_name = "my-eks-node-group"
node_count      = ["3"]
instance_type   = "t3.medium"
vpc_cidr        = "10.0.0.0/16"
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
#private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
eks_role_name      = "eks-cluster-role2"
eks_node_role_name = "eks-node-role"
SG_allow-ssh       = "Main_SG"

#availability_zones = ["us-east-1a", "us-east-1b","us-east-1c", ] ## We are using dat a blocke here so no need to sepcific
