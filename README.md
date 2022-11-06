1.	Create an s3 bucket for the backend.  Copy the bucket name as you will need it later
2.	Create DynamoDB table with the following values:
  a.  Table name: tf-lock-table  
  b.  Partition Key: LockID
  c.	Copy the table name
3.	Clone the git repository.  Move through each subdirectory and fill out these parameters
  a.	Vpc
    i.	Terraform.tfvars
      1.	S3_backend_name = name of your bucket
      2.	S3_backend_region = region that the s3 bucket was created
      3.	Dynamodb_table_name = name of table created in step 2
      4.	Region = aws region to deploy resources
    ii.	Terraform.tf
      1.	Bucket = s3 bucket created for backend
      2.	Region = s3 backend region
      3.	Dynamodb_table = name of table created in step 2
  b.	S3
      i.	Terraform.tfvars
        1.	S3_bucket_name = s3 bucket name for logging and images
    ii.	Terraform.tf
        1.	Bucket = s3 bucket created for backend
        2.	Region = s3 backend region
        3.	Dynamodb_table = name of table created in step 2
  c.	Elb
    i.	Terraform.tf
      1.	Bucket = s3 bucket created for backend
      2.	Region = s3 backend region
      3.	Dynamodb_table = name of table created in step 2
    ii.	Data.tf (for each terraform_remote_state label)
      1.	Bucket = s3 bucket created for backend
      2.	Region = s3 backend region
  d.	Eks
    i.	Terraform.tf
      1.	Bucket = s3 bucket created for backend
      2.	Region = s3 backend region
      3.	Dynamodb_table = name of table created in step 2
    ii.	Data.tf (for each terraform_remote_state label)
      1.	Bucket = s3 bucket created for backend
      2.	Region = s3 backend region
      e.	Ec2-ami
    i.	Terraform.tf
      1.	Bucket = s3 bucket created for backend
      2.	Region = s3 backend region
      3.	Dynamodb_table = name of table created in step 2
    ii.	Data.tf (for each terraform_remote_state label)
      1.	Bucket = s3 bucket created for backend
      2.	Region = s3 backend region
4.	Change directory into the vpc subdirectory.
  a.	Run terraform init to initialize the backend
  b.	Run terraform apply -var-file=”terraform.tfvars”
    i.	This will create a key-pair and output a key file to the current working directory.  This key-pair will be used for ssh into the ec2 instances.  It         will be uploaded to the s3 bucket we create in step 5
    ii.	If you experience errors with nacl association, run the same command again to replace tainted nacl objects
5.	Change into the s3 directory
  a.	Run terraform init
  b.	Run terraform apply
    i.	Enter the you aws account ID as the input variable.  This is used in the bucket policy
  c.	Upload the myKey.pem file to this s3 bucket
6.	Change directory into the eks subdirectory
  a.	Run terraform init
  b.	Run terraform apply -var-file=”terraform.tfvars”
  c.	The coredns addon may take a while to deploy
7.	Change directory into the ec2-ami subdirectory
  a.	Run terraform init
  b.	Run terraform apply
8.	Change directory into the elb subdirectory
  a.	Run terraform init
  b.	Run terraform apply
  
