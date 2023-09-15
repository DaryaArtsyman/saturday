#!/bin/bash

vpc_name="vpc-group-4"
vpc_cidr="10.0.0.0/16"
region="us-east-2"
az1="us-east-2a"
az2="us-east-2b"
az3="us-east-2c"

ec2_instance_name="ec2-group-4"
AMI_ID="ami-01103fb68b3569475"
instance_type="t2.micro"
key_name="new"


#create VPC named "vpc-group-4" with CIDR block 10.0.0.0/16

vpc_id=$(aws ec2 create-vpc --cidr-block $vpc_cidr --tag-specification "ResourceType=vpc,Tags=[{Key=Name,Value=$vpc_name}]" --region $region --query Vpc.VpcId --output text)



# Security group named "sg-group-4"
sg_id=$(aws ec2 create-security-group --group-name Securitygroup4 --description "Demo Security Group" --vpc-id $vpc_id --query GroupId --output text)

#Open inbound ports 22, 80, 443 for everything in security group "sg-group-4"

aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 22 --cidr 0.0.0.0/0 --region $region
aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $region
aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 443 --cidr 0.0.0.0/0 --region $region

# Create 3 public subnets: 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24 in each availability zones respectively (us-east-2a, us-east-2b, us-east-2c)
aws ec2 create-tags --resources $vpc_id --tags Key=Name,Value=vpc-group-4 --region $region
subnet1_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.0.1.0/24 --availability-zone $az1 --query Subnet.SubnetId --output text --region $region)
subnet2_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.0.2.0/24 --availability-zone $az2 --query Subnet.SubnetId --output text --region $region)
subnet3_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.0.3.0/24 --availability-zone $az3 --query Subnet.SubnetId --output text --region $region)

#Create Internet Gateway
igw_id=$(aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text)

#Attach Internet Gateway to VPC "vpc-group-4"
aws ec2 attach-internet-gateway --vpc-id $vpc_id --internet-gateway-id $igw_id

# Launch EC2 Instance
aws ec2 run-instances --image-id $AMI_ID --subnet-id $subnet1_id --security-group-ids $sg_id --instance-type $instance_type --key-name $key_name --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$ec2_instance_name}]" --region $region
~
