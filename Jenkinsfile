pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }

    stages {
        stage('Setup Terraform') {
            steps {
                script {
                    def tfHome = tool name: 'Terraform', type: 'org.jenkinsci.plugins.terraform.TerraformInstallation'
                    env.PATH = "${tfHome}:${env.PATH}"
                }
            }
        }
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/frfranco2026-create/jenkins-terraform.git'
            }
        }
        stage('Init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Validate') {
            steps {
                sh 'terraform fmt -check'
                sh 'terraform validate'
            }
        }
        stage('Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }
        stage('Approval') {
            steps {
                input message: 'Apply this Terraform plan?', ok: 'Apply'
            }
        }
        stage('Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }
}
