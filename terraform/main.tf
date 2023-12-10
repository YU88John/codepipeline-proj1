# Call the networking module
module "networking" {
  source = "./modules/networking"
  az-a   = "us-east-1a" 
  az-b   = "us-east-1b" 
}

# Call the compute module
module "compute" {
  source        = "./modules/compute"
  ami_id        = "ami-001659fb13684a3bd" # my amazon linux 2 ami with Code Deploy and CloudWatch agents
  subnet_ids    = module.networking.subnet_ids
  asg_id        = module.networking.asg_security_group_id
  tg_arn_asg    = module.networking.tg_arn
  tg_dependency = module.networking.tg_creation
  tg_name       = module.networking.tg_name4cd
  alb_name = module.networking.alb_name
}

# Call the database module
module "database" {
  source     = "./modules/database"
  subnet_ids = module.networking.rds_subnet_ids
  vpc_id     = module.networking.vpc_id
  az-a       = "us-east-1a"
  sg_asg_id  = module.networking.asg_security_group_id
}

module "monitoring" {
  source = "./modules/monitoring" 
  asg_id = module.compute.asg_id
  asg_dependency = module.compute.asg_dependency
  alb_arn = module.networking.alb_arn
  alb_dependency = module.networking.alb_dependency
  rds_dependency = module.database.rds_dependency
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
