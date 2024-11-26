# AWS Region
variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
}

variable "aws_Access_key" {
  description = "The AWS region to deploy resources"
  type        = string

}
variable "aws_Secrete_key" {
  description = "The AWS region to deploy resources"
  type        = string

}
variable "cluster_name" {
  default = "my-eks-cluster"
  type    = string
}

variable "node_group_name" {
  default = "my-eks-node-group"
  type    = string
}

#variable "desired_capacity" {
# description = "Desired number of worker nodes"
#type        = number
#default     = 3
#}

#variable "max_size" {
# description = "Maximum number of worker nodes"
#type        = number
#default     = 3
#}

#variable "min_size" {
# description = "Minimum number of worker nodes"
# type        = number
#default     = 1
#}

variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}
variable "node_count" {

  description = "List of node counts for different groups."
  #type        = list(number)
  default = 3 # Example: 3 nodes in each group#}
}



#variable "node_count" {
#1  description = "List of node counts for different groups."
#  type        = list(number)
#  default     = [3, 3, 3] # Example: 3 nodes in each group
#}

#variable "vpc_cidr" {
# default = "10.0.0.0/16"
#}
# VPC CIDR Block
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string

}
# Availability Zones
#variable "availability_zones" {
# description = "List of availability zones"  ## We are using dat a blocke here so no need to sepcific
#type        = list(string)

#}
variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

#variable "private_subnets" {
# type    = list(string)
# default = ["10.0.3.0/24", "10.0.4.0/24"]
#}

variable "eks-cluster-role2" {
  default = "eks-cluster-role2"
}

variable "eks-node-role" {
  default = "eks-node-role"
}
variable "ingress_ports" {
  type    = list(string)
  default = [22, 80, 443, 389, 3389, 8001, 8002, 8000, 9100, 8010, 9443, 8080]
}
variable "SG_allow-ssh" {}
