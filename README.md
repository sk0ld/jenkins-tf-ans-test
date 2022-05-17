Demo of usage Jenkins/Terraform/Ansible with yandex cloud
=========

Short info
------------

Tested on Ubuntu 20.04

Terraform and Ansible scenarios create instances (Ubuntu 20.04 LTS) on YC:

1) Jenkins to start the job and enter image tag (1.0.0 by default)
1) Terraform for creation: 2 VMs (vm-dev and vm-prod), s3-bucket storage
2) Ansible : to deploy docker, build docker image to get artifact (war) and share it to s3-bucket
3) Ansible: to build prod image, push image to registry and pull image for staging

After the deployment you will get public ip addresses of VM instances.
Follow http://vm-prod-public-ip:8080/hello-1.0
You will see boxfuse web app

Preparation:
------------

On master server:
------------

Install jenkins (with git plugin), terraform, ansible, git

```
Create Jenkins job (pipeline) with parameters:
string parameter - name: image_version, default value: 1.0.0
Pipeline from Git SCM https://github.com/sk0ld/jenkins-tf-ans-test.git
Branch: */main
Script Path: Jenkinsfile
```


Restrictions for keys inside /home/pcadm (account pcadm is used for current example) :
```
cd /home/pcadm
chmod 0600 key.json .private_yc .s3cfg
chown jenkins:root  key.json .private_yc .s3cfg
```

ssh keys and additial configs:
-----------------------------

Generate and put private ssh key for your VMs here:
```
/home/your_user/.private_yc
```

To create user metadata (for example for user pcadm):
```
touch /home/your_user/meta.txt
```

Content of meta.txt :
```
#cloud-config
users:
  - name: pcadm
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
      ssh-authorized-keys:
      - ssh-rsa AAAAB3Nza......OjbSMRX pcadm@vm-ubuntu210
```


Terraform installation:
https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started

YC CLI install:
```
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
```

YC init to initialize your profile with token:
```
yc init
```
Follow YC manual: https://cloud.yandex.ru/docs/cli/quickstart


Prepare access to Yandex Cloud docker registry in advance: https://cloud.yandex.com/en/docs/container-registry/operations/registry/registry-create


https://cloud.yandex.com/en/docs/container-registry/operations/authentication



To create file with your IDs (inside project directory):
```
touch wp.auto.tfvars
```
Example of content wp.auto.tfvars:
```
folder_id = "your_folder_id"
sa_id = "your_sa_id"
cloud_id = "your_cloud_id"
token = "your_token"
```

Settings for terraform (already added to repository):
```
touch ~/.terraformrc
```
Content of .terraformrc:
```
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```


Additional requirements
------------

Create additional virtual directory in Yandex Cloud. 
There is directory with name tf-dir for current example.
Delete all networks inside directory or contact YC support to extend quantity of networks.

Info for S3 Bucket
------------------

Static key for service account:
https://github.com/yandex-cloud/docs/blob/master/en/iam/operations/sa/create-access-key.md

Configure service account to use S3 storage:
https://cloud.yandex.com/en/docs/storage/tools/s3cmd

Copy S3 config to your user directory:
```
cp ~/.s3cfg /home/your_user/.s3cfg
```