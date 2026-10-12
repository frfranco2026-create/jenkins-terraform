pipeline {
    agent any

    parameters {
        string(name: 'SSH_ALLOWED_CIDR', defaultValue: '187.13.182.162/32', description: 'CIDR allowed to SSH into the EC2 instance')
    }

    environment {
        TF_VAR_ssh_allowed_cidr = "${params.SSH_ALLOWED_CIDR}"
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
        stage('Init') {
            steps {
                sh 'terraform init -reconfigure'
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
