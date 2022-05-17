pipeline {
    agent any
    environment {
        TF_VARS = "/home/pcadm/tech/wp.auto.tfvars"
        PRIV_KEY = "/home/pcadm/.private_yc"
        
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
              rm -rf hosts.txt
              terraform apply tfplan
              '''
            }
        }  
         stage ('Ansible playbook') {
             steps {
              sh '''
              ansible-playbook dev-prod-docker.yml -i hosts.txt --private-key $PRIV_KEY --user pcadm -vv
              '''
            }
        }  

         stage ('Yandex Cloud infra remove') {
            steps {
              sh '''
              sleep 1m
              terraform destroy --auto-approve
              '''
            }
        }
  }
}