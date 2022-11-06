cluster-name    = "eks-coalfire-cluster"
eks-version     = 1.23
nodegroup-name  = "Production"
instance_types  = ["t2.micro"]
desired_size    = 3
min_size        = 3
max_size        = 6
max_unavailable = 1