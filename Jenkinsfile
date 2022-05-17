pipeline {
    agent any
    environment {
        TF_VARS = "/home/pcadm/tech/wp.auto.tfvars"
        
    }
    stages {
         stage ('Yandex Cloud infra preparation') {
            steps {
              sh '''
              cp .terraformrc ~/
              cp $TF_VARS .
              terraform init
              terraform plan 
              terraform apply --auto-approve
              '''
            }
        }  
         stage ('Ansible playbook') {
             steps {
              sh '''
              ansible-playbook dev-prod-docker.yml -i hosts.txt --extra-vars image_version=$image_version -vv
              '''
            }
        }  

         stage ('Yandex Cloud infra remove') {
            steps {
              sh '''
              sleep 3m
              terraform destroy --auto-approve
              '''
            }
        }
  }
}