# Multi-Service Node.js E-commerce Application - Terraform + Docker + AWS

## Architecture

Internet -> Security Group :3000 -> Ubuntu EC2 -> Docker `ecommerce-net`

Containers:
- `ecommerce-frontend` - port 3000 (public)
- `user-service` - port 3001
- `products-service` - port 3002
- `orders-service` - port 3003
- `cart-service` - port 3004

Terraform creates a custom VPC (`10.10.0.0/16`), public subnet (`10.10.1.0/24`), Internet Gateway, route table, security group, and one Ubuntu 22.04 EC2 instance. EC2 user-data installs Docker, pulls the five Docker Hub images, creates a Docker network, and starts all containers.

## 1. Prerequisites

Install/configure:
- Docker
- Terraform
- AWS CLI with working credentials
- Docker Hub account

Validate AWS:

```bash
aws sts get-caller-identity
```

## 2. Build and test all images locally

Replace `YOUR_DOCKERHUB_USERNAME` in the commands below.

### User service
```bash
cd user-service
docker build -t YOUR_DOCKERHUB_USERNAME/user-service:latest .
docker run --rm -p 3001:3001 YOUR_DOCKERHUB_USERNAME/user-service:latest
# Open http://localhost:3001
```

### Products service
```bash
cd ../products-service
docker build -t YOUR_DOCKERHUB_USERNAME/products-service:latest .
docker run --rm -p 3002:3002 YOUR_DOCKERHUB_USERNAME/products-service:latest
```

### Orders service
```bash
cd ../orders-service
docker build -t YOUR_DOCKERHUB_USERNAME/orders-service:latest .
docker run --rm -p 3003:3003 YOUR_DOCKERHUB_USERNAME/orders-service:latest
```

### Cart service
```bash
cd ../cart-service
docker build -t YOUR_DOCKERHUB_USERNAME/cart-service:latest .
docker run --rm -p 3004:3004 YOUR_DOCKERHUB_USERNAME/cart-service:latest
```

### Frontend
```bash
cd ../frontend
docker build -t YOUR_DOCKERHUB_USERNAME/ecommerce-frontend:latest .
docker run --rm -p 3000:3000 YOUR_DOCKERHUB_USERNAME/ecommerce-frontend:latest
# Open http://localhost:3000
```

Stop each test container with Ctrl+C before starting the next container.

## 3. Push images to Docker Hub

```bash
docker login

docker push YOUR_DOCKERHUB_USERNAME/user-service:latest
docker push YOUR_DOCKERHUB_USERNAME/products-service:latest
docker push YOUR_DOCKERHUB_USERNAME/orders-service:latest
docker push YOUR_DOCKERHUB_USERNAME/cart-service:latest
docker push YOUR_DOCKERHUB_USERNAME/ecommerce-frontend:latest
```

All repositories must be public unless you add Docker Hub credentials to the EC2 bootstrap process.

## 4. Terraform deployment

```bash
cd ../terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set your Docker Hub username.

Then:

```bash
terraform fmt
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

Terraform prints:
- EC2 public IP
- EC2 public DNS
- Frontend URL
- `/api-status` URL

Because user-data needs to install Docker and pull images, give the instance a short moment after `terraform apply` completes before opening the URL.

## 5. Verify deployment

Frontend:
```bash
curl http://PUBLIC_IP:3000
```

Backend integration through frontend:
```bash
curl http://PUBLIC_IP:3000/api-status
```

Expected: all four backends report `status: UP`.

If SSH is configured:
```bash
ssh ubuntu@PUBLIC_IP
sudo docker ps
sudo docker logs ecommerce-frontend
sudo cat /var/log/ecommerce-user-data.log
curl http://127.0.0.1:3001
curl http://127.0.0.1:3002
curl http://127.0.0.1:3003
curl http://127.0.0.1:3004
```

## 6. Evidence / screenshots for submission

Capture these screenshots:
1. Five Dockerfiles/source folders.
2. Docker Hub showing all five repositories/tags.
3. `terraform validate` successful.
4. `terraform apply` completion and Terraform outputs.
5. AWS VPC/subnet/route table/security group.
6. EC2 instance in Running state with public IP.
7. `docker ps` showing all five containers.
8. Browser showing `Frontend is Live`.
9. Browser or curl showing `/api-status` with all four backend services healthy.

## 7. Clean up

```bash
terraform destroy -auto-approve
```

## Security note

For an exam/demo, the frontend is exposed directly on port 3000. Backends are bound to EC2 loopback and communicate over the private Docker network. For production, use an ALB/reverse proxy on HTTPS, private subnets for workloads, IAM roles, encrypted storage, secrets management, observability, image scanning, and restricted SSH access.
