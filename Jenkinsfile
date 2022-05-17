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
              rm -rf hosts.txt  
              terraform plan
              terraform apply --auto-approve
              '''
            }
        }  
         stage ('Ansible playbook') {
             steps {
              sh '''
              ansible-playbook dev-prod-docker.yml -i hosts.txt -vv
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