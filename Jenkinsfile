pipeline {
    environment {
        DOCKER_ID = "hasaron"
        DOCKER_IMAGE = "datascientestapi"
        DOCKER_TAG = "v.${BUILD_ID}.0"
    }
    agent any
    stages {
        stage('Docker Build') {
            steps {
                script {
                    // Supprimer le conteneur Docker s'il existe déjà
                    sh 'docker rm -f jenkins || true'
                    // Construire l'image Docker
                    sh "docker build -t $DOCKER_ID/$DOCKER_IMAGE:$DOCKER_TAG ."
                    // Attendre un certain temps
                    sleep 6
                }
            }
        }
        stage('Docker run') {
            steps {
                script {
                    // Exécuter le conteneur Docker
                    sh "docker run -d -p 80:80 --name jenkins $DOCKER_ID/$DOCKER_IMAGE:$DOCKER_TAG"
                    // Attendre un certain temps
                    sleep 10
                }
            }
        }
        stage('Test Acceptance') {
            steps {
                script {
                    // Tester l'acceptation en envoyant une requête curl à localhost
                    sh 'curl localhost'
                }
            }
        }
        stage('Docker Push') {
            environment {
                // Récupérer le mot de passe Docker Hub
                DOCKER_PASS = credentials("DOCKER_HUB_PASS")
            }
            steps {
                script {
                    // Se connecter à Docker Hub et pousser l'image
                    sh "docker login -u $DOCKER_ID -p $DOCKER_PASS"
                    sh "docker push $DOCKER_ID/$DOCKER_IMAGE:$DOCKER_TAG"
                }
            }
        }
        stage('Deploiement en dev') {
            environment {
                // Récupérer la configuration Kubeconfig
                KUBECONFIG = credentials("config")
            }
            steps {
                script {
                    // Configurer Kubeconfig et déployer sur l'environnement de développement
                    sh 'rm -Rf .kube'
                    sh 'mkdir .kube'
                    sh 'cat $KUBECONFIG > .kube/config'
                    sh 'cp fastapi/values.yaml values.yml'
                    sh "sed -i 's+tag.*+tag: ${DOCKER_TAG}+g' values.yml"
                    sh 'cat values.yml'
                    sh 'helm upgrade --install app fastapi --values=values.yml --namespace dev'
                }
            }
        }
        stage('Deploiement en staging') {
            environment {
                // Récupérer la configuration Kubeconfig
                KUBECONFIG = credentials("config")
            }
            steps {
                script {
                    // Configurer Kubeconfig et déployer sur l'environnement de staging
                    sh 'rm -Rf .kube'
                    sh 'mkdir .kube'
                    sh 'cat $KUBECONFIG > .kube/config'
                    sh 'cp fastapi/values.yaml values.yml'
                    sh "sed -i 's+tag.*+tag: ${DOCKER_TAG}+g' values.yml"
                    sh 'cat values.yml'
                    sh 'helm upgrade --install app fastapi --values=values.yml --namespace staging'
                }
            }
        }
        stage('Deploiement en prod') {
            environment {
                // Récupérer la configuration Kubeconfig
                KUBECONFIG = credentials("config")
            }
            steps {
                timeout(time: 15, unit: "MINUTES") {
                    input message: 'Do you want to deploy in production ?', ok: 'Yes'
                }
                script {
                    // Configurer Kubeconfig et déployer sur l'environnement de production
                    sh 'rm -Rf .kube'
                    sh 'mkdir .kube'
                    sh 'cat $KUBECONFIG > .kube/config'
                    sh 'cp fastapi/values.yaml values.yml'
                    sh "sed -i 's+tag.*+tag: ${DOCKER_TAG}+g' values.yml"
                    sh 'cat values.yml'
                    sh 'helm upgrade --install app fastapi --values=values.yml --namespace prod'
                }
            }
        }
    }
    post {
        always {
            // Supprimer les namespaces dev, qa et staging après chaque exécution
            sh 'kubectl delete namespace dev || true'
            sh 'kubectl delete namespace qa || true'
            sh 'kubectl delete namespace staging || true'
        }
    }
}

