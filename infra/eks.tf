# Minimal EKS cluster for Argo CD deployment
resource "aws_eks_cluster" "main" {
  name     = "ehr-poc-eks"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  }
}

resource "aws_iam_role" "eks_cluster" {
  name = "eksClusterRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "eks.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "default"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  instance_types = ["t3.micro"]
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
}

resource "aws_iam_role" "eks_nodes" {
  name = "eksNodeRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_nodes_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_nodes_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}


output "eks_cluster_id" {
  value = aws_eks_cluster.main.id
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "eks_cluster_certificate_authority_data" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

output "eks_cluster_kubeconfig" {
  value = <<EOF
apiVersion: v1
clusters:
  - cluster:
      server: ${aws_eks_cluster.main.endpoint}
      certificate-authority-data: ${aws_eks_cluster.main.certificate_authority[0].data}
    name: ${aws_eks_cluster.main.name}
contexts:
  - context:
      cluster: ${aws_eks_cluster.main.name}
      user: aws
    name: ${aws_eks_cluster.main.name}
current-context: ${aws_eks_cluster.main.name}
kind: Config
users:
  - name: aws
    user:
      exec:
        apiVersion: client.authentication.k8s.io/v1alpha1
        command: aws
        args:
          - "eks"
          - "get-token"
          - "--cluster-name"
          - "${aws_eks_cluster.main.name}"
EOF
}
