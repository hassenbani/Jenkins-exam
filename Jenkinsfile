pipeline {
    agent any

    environment {
        KUBECONFIG = '/home/ubuntu/.kube/config' // Chemin vers le fichier de configuration Kubernetes
        DOCKER_HUB_USERNAME = 'hasaron' // Nom d'utilisateur Docker Hub
        DOCKER_HUB_PASS = credentials('DOCKER_HUB_PASS') // Identifiants Docker Hub
        NAMESPACES = ['staging', 'dev', 'qa', 'prod'] // Noms des espaces de noms Kubernetes
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build and Push Docker Images') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_HUB_USERNAME, DOCKER_HUB_PASS) {
                        docker.build('your-docker-image:latest', './cast-service')
                        docker.build('your-docker-image:latest', './movie-service')
                        docker.push('your-docker-image:latest')
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    for (String namespace in NAMESPACES) {
                        def deployEnv = "deploy-${namespace}"
                        sh "helm upgrade --install ${deployEnv} ./cast-service --namespace ${namespace} -f ./cast-service/values.yaml"
                        sh "helm upgrade --install ${deployEnv} ./movie-service --namespace ${namespace} -f ./movie-service/values.yaml"
                    }
                }
            }
        }
    }
}

