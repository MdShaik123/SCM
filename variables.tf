variable "public_cidr_range" {

    default = ["10.0.0.0/24","10.0.1.0/24","10.0.2.0/24"]
    type = list
  
}

variable "private_cidr_range" {

    default = ["10.0.3.0/24","10.0.4.0/24","10.0.5.0/24"]
    type = list
  
}

variable "data_cidr_range" {

    default = ["10.0.6.0/24","10.0.7.0/24","10.0.8.0/24"]
    type = list
  
}