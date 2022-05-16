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
              rm -rf hosts.txt tfplan 
              terraform init  
              terraform plan --out=tfplan
              terraform apply tfplan
              '''
            }
        }  
         stage ('Ansible playbook') {
             steps {
              sh '''
              cp ansible.cfg ~/ 
              ansible-playbook dev-prod-docker.yml -i hosts.txt --private-key $PRIV_KEY --user pcadm -vv
              '''
            }
        }  

         stage ('Yandex Cloud infra remove') {
            steps {
              sh '''
              sleep 2m
              terraform destroy --auto-approve
              '''
            }
        }
  }
}