output "cluster_id" {
  value = aws_eks_cluster.project4.id
}

output "node_group_id" {
  value = aws_eks_node_group.project4.id
}

output "vpc_id" {
  value = aws_vpc.project4_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.project4_subnet[*].id
}