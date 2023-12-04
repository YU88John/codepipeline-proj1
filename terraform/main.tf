# Call the networking module
module "networking" {
  source = "./modules/networking"
  az-a   = "us-east-1a" # Update with your Availability Zone configuration
  az-b   = "us-east-1b" # Update with your Availability Zone configuration
}

# Call the compute module
module "compute" {
  source        = "./modules/compute"
  ami_id        = "ami-0036842d752c02190"
  subnet_ids    = module.networking.subnet_ids
  asg_id        = module.networking.asg_security_group_id
  tg_arn_asg    = module.networking.tg_arn
  tg_dependency = module.networking.tg_creation
}

# Call the database module
module "database" {
  source     = "./modules/database"
  subnet_ids = module.networking.subnet_ids
  vpc_id     = module.networking.vpc_id
  az-a       = "us-east-1a"
  sg_asg_id  = module.networking.asg_security_group_id
}

# Output some useful information if needed
output "vpc_id" {
  value = module.networking.vpc_id
}

output "subnet_ids" {
  value = module.networking.subnet_ids
}

output "asg_id" {
  value = module.compute.asg_id
}

output "rds_endpoint" {
  value = module.database.rds_endpoint
}
