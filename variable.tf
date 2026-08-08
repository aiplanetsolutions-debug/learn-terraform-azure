variable "eastus_location" {
  type        = string
  description = "The region for our secondary tutorial virtual network"
  default     = "eastus" 
}

variable "seasia_location" {
  type        = string
  description = "The region for our secondary tutorial virtual network"
  default     = "Southeast Asia" 
}

variable "eastus2_location" {
  type        = string
  description = "The region for our secondary tutorial virtual network"
  default     = "eastus2" 
}

variable "vm_size" {
  type    = string
  default = "Standard_D2s_v7" # Originally from your parameter file
}

variable "vm_name_1" {
  type    = string
  default = "testvm1"
}

variable "nic_name_1" {
  type    = string
  default = "testvm1-nic"
}

variable "vm_name_2" {
  type    = string
  default = "testvm2"
}

variable "nic_name_2" {
  type    = string
  default = "testvm2-nic"
}

variable "admin_username" {
  type    = string
  default = "TestUser"
}

variable "admin_password" {
  type        = string
  default     = "Welcome@123!" # Replace with your secure lab password
  sensitive   = true
}


