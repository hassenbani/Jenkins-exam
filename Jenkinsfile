pipeline {
    agent any

    stages {
        stage('Cloning repository') {
            steps {
                git 'git@github.com:hassenbani/Jenkins-exam.git'
            }
        }

        stage('Building Docker images') {
            steps {
                script {
                    docker.build('movie-service', './movie-service')
                    docker.build('cast-service', './cast-service')
                }
            }
        }

        stage('Pushing Docker images to DockerHub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerHubCredentials') {
                        docker.image('movie-service').push('latest')
                        docker.image('cast-service').push('latest')
                    }
                }
            }
        }

        stage('Deploying to Kubernetes') {
            steps {
                script {
                    // Apply Kubernetes manifests for each service in the respective namespaces
                    sh 'kubectl apply -f movie-service/kubernetes-manifests/dev.yaml -n dev'
                    sh 'kubectl apply -f cast-service/kubernetes-manifests/dev.yaml -n dev'
                    // Similar steps for other environments like QA, staging, prod
                }
            }
        }

        stage('Manual deployment to prod') {
            when {
                branch 'master'
            }
            steps {
                input 'Deploy to prod?'
                script {
                    // Apply Kubernetes manifests for prod environment
                    sh 'kubectl apply -f movie-service/kubernetes-manifests/prod.yaml -n prod'
                    sh 'kubectl apply -f cast-service/kubernetes-manifests/prod.yaml -n prod'
                }
            }
        }
    }

    post {
        always {
            // Clean up any resources if needed
            sh 'kubectl delete namespace dev'
            sh 'kubectl delete namespace qa'
            sh 'kubectl delete namespace staging'
        }
    }
}

// Définition des identifiants DockerHub
credentials {
    id = 'dockerHubCredentials'
    username = 'hasaron@gmail.com'
    password = env.DOCKER_HUB_PASS
}


