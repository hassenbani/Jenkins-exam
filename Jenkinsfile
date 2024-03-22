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
                branch 'master'
                beforeAgent true
                environment {
                    deploymentApproval = input message: 'Deploy to production?', ok: 'Deploy'
                }
            }
            steps {
                script {
                    sh 'bash deploy_prod.sh'
                }
            }
        }
    }
}

