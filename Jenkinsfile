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
              rm -rf tfplan 
              terraform init  
              terraform plan --out=tfplan
              terraform apply tfplan
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