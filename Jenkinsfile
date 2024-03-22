pipeline {
    agent any

    environment {
        KUBECONFIG = '/path/to/kubeconfig'
        DOCKER_REGISTRY = 'hasaron'
        HELM_CHART_REPO = 'your-helm-chart-repo'
    }

    stages {
        stage('Build') {
            steps {
                script {
                    sh 'bash build.sh'
                }
            }
        }
        
        stage('Test') {
            steps {
                sh 'pytest'
            }
        }

        stage('Deploy') {
            when {
                branch 'master'
            }
            steps {
                script {
                    sh 'bash deploy.sh'
                }
            }
        }

        stage('Deploy Production') {
            when {
                beforeAgent true
                expression { branch 'master' }
            }
            steps {
                script {
                    def deploymentApproval = input message: 'Deploy to production?', ok: 'Deploy'
                }
            }
        }
    }
}

