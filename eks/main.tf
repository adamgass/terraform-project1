locals {
  PrivateSubnet1 = data.terraform_remote_state.vpc.outputs.PvtSN1_id
  PrivateSubnet2 = data.terraform_remote_state.vpc.outputs.PvtSN2_id
  PrivateSubnet3 = data.terraform_remote_state.vpc.outputs.PvtSN3_id
  PublicSubnet1 = data.terraform_remote_state.vpc.outputs.PubSN1_id
  PublicSubnet2 = data.terraform_remote_state.vpc.outputs.PubSN2_id
  PublicSubnet3 = data.terraform_remote_state.vpc.outputs.PubSN3_id
}

resource "aws_eks_cluster" "eks-cluster" {
  name     = var.cluster-name
  role_arn = aws_iam_role.eksClusterRole.arn
  version  = var.eks-version

  vpc_config {
    subnet_ids = [local.PrivateSubnet1, local.PrivateSubnet2, local.PrivateSubnet3]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
  ]
}

resource "aws_iam_role" "eksClusterRole" {
  name = "eksClusterRole"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eksClusterRole.name
}


resource "aws_eks_addon" "vpc-cni" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "vpc-cni"
}


resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = "kube-proxy"
}

# create node group
resource "aws_eks_node_group" "nodegroup1" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = var.nodegroup-name
  node_role_arn   = aws_iam_role.AmazonEKSNodeRole.arn
  subnet_ids      = [local.PrivateSubnet1, local.PrivateSubnet2, local.PrivateSubnet3]
  instance_types  = var.instance_types

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = var.max_unavailable
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}


# IAM role for nodegroup
resource "aws_iam_role" "AmazonEKSNodeRole" {
  name = "AmazonEKSNodeRole"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  tags = {
    "kubernetes.io/cluster/${var.cluster-name}" = "owned"
  }
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.AmazonEKSNodeRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.AmazonEKSNodeRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.AmazonEKSNodeRole.name
}

