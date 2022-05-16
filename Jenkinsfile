pipeline {
    agent any
    stages {
         stage ('Yandex Cloud infra preparation') {
            steps {
              sh '''
              cp .terraformrc ~/
              cp /home/pcadm/tech/wp.auto.tfvars . && rm -rf hosts.txt  
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
              ansible-playbook dev-prod-docker.yml -i hosts.txt --private-key /home/pcadm/.private_yc --user pcadm -vv
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