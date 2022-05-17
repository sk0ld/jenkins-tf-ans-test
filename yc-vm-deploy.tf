terraform {
    required_providers {
      yandex = {
        source = "yandex-cloud/yandex"
      }
    }
  }
  
  
  variable "cloud_id" {
    type = string
    description = "Yandex Cloud id"
  }
  
  variable "folder_id" {
    type = string
    description = "Yandex Cloud folder id"
  }
  
  variable "sa_id" {
    type = string
    description = "Yandex Cloud service account id"
  }
  
  variable "token" {
    type = string
    description = "Yandex Cloud token"
  }
  
  
locals {
    image_id = "fd8sc0f4358r8pt128gg"
    zone = "ru-central1-b"
    user_name = "pcadm"
    bucket_name = "tf-bucket-yc"
    pub_ip_vm1 = yandex_compute_instance.vm1.network_interface.0.nat_ip_address
    pub_ip_vm2 = yandex_compute_instance.vm2.network_interface.0.nat_ip_address
  }
  provider "yandex" {
    token     = var.token
    cloud_id  = var.cloud_id
    folder_id = var.folder_id
    zone      = local.zone
  }
  
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = var.sa_id
  description        = "static access key for object storage"
}

resource "yandex_storage_bucket" "tf-bucket-yc" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = local.bucket_name
}

resource "yandex_container_registry" "tf-reg-yc" {
  name = "tf-reg-yc"
  folder_id = "var.folder_id"
  labels = {
    my-label = "yc-custom-label"
  }
}

  resource "yandex_vpc_network" "network-1" {
    name = "network1"
  }
  resource "yandex_vpc_subnet" "subnet-1" {
    name           = "subnet1"
    zone           = "ru-central1-b"
    network_id     = yandex_vpc_network.network-1.id
    v4_cidr_blocks = ["10.129.0.0/24"]
  }
  
  resource "yandex_compute_instance" "vm1" {
    name        = "vm-dev"
    allow_stopping_for_update = true
  
    resources {
      cores  = 2
      memory = 2
      core_fraction = 100
    }
  
    boot_disk {
      initialize_params {
        image_id = local.image_id
        type     = "network-ssd"
        size = 15
      }
    }
    network_interface {
        subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
        nat = true
      }
    
      metadata = {
        user-data = "${file("/home/${local.user_name}/meta.txt")}"
      }

      provisioner "remote-exec" {
        inline = [
          "cat /etc/os-release"
              ]
        connection {
          type     = "ssh"
          user     = local.user_name
          private_key = "${file("/home/${local.user_name}/.private_yc")}"
          host     = self.network_interface.0.nat_ip_address
        }
      }
    }  
    
    

    resource "yandex_compute_instance" "vm2" {
    name        = "vm-prod"
    allow_stopping_for_update = true
  
    resources {
      cores  = 2
      memory = 2
      core_fraction = 100
    }
  
    boot_disk {
      initialize_params {
        image_id = local.image_id
        type     = "network-ssd"
        size = 15
     }
    }

    network_interface {
        subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
        nat = true
      }
    
      metadata = {
        user-data = "${file("/home/${local.user_name}/meta.txt")}"
      } 

      provisioner "remote-exec" {
        inline = [
          "cat /etc/os-release"
              ]
        connection {
          type     = "ssh"
          user     = local.user_name
          private_key = "${file("/home/${local.user_name}/.private_yc")}"
          host     = self.network_interface.0.nat_ip_address
        }
      }
    }  
    
    output "public_ip_address_vm1" {
        value = local.pub_ip_vm1
      }  

    output "public_ip_address_vm2" {
        value = local.pub_ip_vm2
      }

     resource "null_resource" "ansible_hosts" {
  provisioner "local-exec" {
          command = "echo '[dev]\n${local.pub_ip_vm1}\n\n[prod]\n${local.pub_ip_vm2}' > hosts.txt"
  }
    }