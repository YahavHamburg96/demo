output "eks_node_group_sg" {
  value = module.eks_al2023.node_security_group_id
}

output "cluster_name" {
  value = module.eks_al2023.cluster_name
}

