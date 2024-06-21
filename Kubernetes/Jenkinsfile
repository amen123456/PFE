pipeline {
    agent any
    environment {
        ANSIBLE_PLAYBOOK_PATH = "/home/amen/PFE/Kubernetes/tasks/prepare_kubernetes.yml"
        INVENTORY_PATH = "/home/amen/PFE/Kubernetes/inventory.txt"
        SSH_KEY = "/var/lib/jenkins/.ssh/id_rsa" 
    }
    stages {
        stage('Cleanup and Git Checkout') {
            steps {
                cleanWs()
                echo 'Cleaning Workspace'
                echo 'Pulling ... '
                git branch: 'main',
                url: 'https://github.com/amen123456/PFE.git'
            }
        }
        stage('Install OpenJDK 11') {
            steps {
                script {
                        sh 'sudo apt-get install openjdk-11-jdk'
                }
            }
        }
        stage('Prepare Environment') {
            steps {
                echo "Setting up environment for Ansible"
                sh 'chmod 600 ${SSH_KEY}' 
            }
        }
        stage('Deploy Kubernetes Cluster') {
            steps {
                script {
                    echo "Running Ansible Playbook to deploy Kubernetes cluster."
                    ansiblePlaybook(
                        playbook: "${ANSIBLE_PLAYBOOK_PATH}",
                        inventory: "${INVENTORY_PATH}",
                        extras: "--private-key ${SSH_KEY} -u root"
                    )
                }
            }
        }
    }

    post {
        success {
            echo 'Déploiement réussi !'
        }
        failure {
            echo 'Le déploiement a échoué.'
        }
    }
}
