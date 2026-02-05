pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = "true"
        AWS_DEFAULT_REGION = "us-east-1"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                  terraform --version
                  terraform init -input=false
                '''
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                  terraform plan \
                    -input=false \
                    -out=tfplan
                '''
            }
        }

        stage('Approval') {
            steps {
                input message: 'Approve Terraform Apply?'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh '''
                  terraform apply \
                    -input=false \
                    -auto-approve \
                    tfplan
                '''
            }
        }
    }

    post {
        success {
            echo 'Terraform environment deployed successfully'
        }
        failure {
            echo 'Terraform deployment failed'
        }
    }
}
