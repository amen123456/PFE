pipeline {
    agent any
    tools {
        terraform 'Terraform'
    }
    stages {
        stage('Git Checkout') {
            steps {
                echo 'Pulling ... '
                git branch: 'main',
                url: 'https://github.com/amen123456/Terraform.git'
            }
        }
        stage('Terraform Init') {
            steps {
                script {
                    sh 'terraform init -upgrade'
                }
            }
        }
        stage('Terraform Plan') {
            steps {
                script {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                script {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }
    post {
        failure {
            echo 'The build failed. Please check the logs to identify the issue.'
        }
        success {
            echo 'Build was successful. Terraform changes have been applied.'
        }
        always {
            echo 'Pipeline execution is complete.'
        }
    }
}
