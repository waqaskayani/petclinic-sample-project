locals {
    azs                         = slice(data.aws_availability_zones.available.names, 0, var.az_count)
    private_subnet_az_tags      = { for az in local.azs : az => { Name = "private-subnet-${az}-${var.environment}" } }
    public_subnet_az_tags       = { for az in local.azs : az => { Name = "public-subnet-${az}-${var.environment}" } }
    private_rt_az_tags          = { Name = "private-rt-${var.environment}" }
    public_rt_az_tags           = { Name = "public-rt-${var.environment}" }
    default_rt_az_tags          = { Name = "default-rt-${var.environment}" }
    nat_tags                    = { Name = "nat-gateway-${var.environment}" }
}
