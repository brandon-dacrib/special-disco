# Check out the `working` branch if you want to test this
# Task Overview: Run an ALB fronted service in a vpc in ECS

## Assumptions
* you have a current terraform binary for your [platform](https://developer.hashicorp.com/terraform/install) 1.9.5 at time of writing. 
* you have have the created the s3 bucket and dynamodb table defined in state.tf + have needed permissions to write to them. Example in the `getting-started` directory. 

## Assignment Requirements:

### 1. Networking:
- **VPC**:
  - Create a VPC with public subnets for the ALB and private subnets for the ECS tasks.
  - Set up NAT Gateways in each availability zone to allow ECS tasks in private subnets to access the internet without exposing them publicly.
  - Create an Internet Gateway for public subnets, enabling NAT Gateways and ALB access to the internet.

- **Routing**:
  - Configure route tables to ensure traffic from private subnets is routed through the NAT Gateways.
  - Ensure public subnets are routed through the Internet Gateway.

### 2. Core Infrastructure:
- **ECS Cluster**:
  - Deploy an Amazon ECS cluster using Fargate.
  - Spread ECS tasks across at least two availability zones.
  - Configure ECS tasks to run the provided Docker image `crccheck/hello-world` on port 8000.
  - Expose the service to the world on port 80 via an Application Load Balancer (ALB).
  - ALB should forward traffic from port 80 to ECS tasks on port 8000.
  
- **Load Balancer**:
  - Set up an ALB to route traffic to the ECS tasks.
  - Enable centralized logging for the ALB using CloudWatch Logs.
  - Configure security groups for the ALB to allow public access on port 80.

### 3. State Management:
- **Terraform State**:
  - Store the Terraform state remotely in an encrypted S3 bucket.
  - Use DynamoDB for state locking to manage concurrent Terraform operations.

### 4. Security:
- **IAM Roles**:
  - Use IAM roles for ECS tasks to securely access AWS resources.
  - Ensure all S3 buckets storing logs and state are encrypted.

- **Security Groups**:
  - Configure security groups to restrict traffic appropriately.
  - ALB should allow traffic on port 80 from the internet.
  - ECS tasks should only allow traffic from the ALB.

### 5. Monitoring & Alerts:
- **CloudWatch Monitoring**:
  - Implement CloudWatch monitoring for ECS tasks and ALB.
  - Set up centralized logging for ECS tasks and ALB using CloudWatch Logs.

### 6. Additional Considerations:
- **Optional Resources**:
  - Optionally, deploy an RDS PostgreSQL database or CloudFront distribution.
  - Set up a CI/CD pipeline (e.g., GitHub Actions) to automate deployment.

## Project Structure and Best Practices:
- **Modular Terraform Code**:
  - Organize the code into reusable modules (VPC, ECS, ALB, security groups).
  - Use variables and outputs effectively.
  - Ensure the code follows best practices for Terraform, including documentation and comments.
