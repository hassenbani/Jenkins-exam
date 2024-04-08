pipeline {
    environment {
        DOCKER_ID = "hasaron" // Remplacez cela par votre ID Docker
        DOCKER_IMAGE = "datascientestapi"
        DOCKER_TAG = "v.${BUILD_ID}.0"
        KUBECONFIG = credentials("config")
        DOCKER_PASS = credentials("DOCKER_HUB_PASS")
    }
    agent any

    stages {
        stage('Docker Build Movie Service') {
            steps {
                script {
                    sh '''
                    docker rm -f jenkins
                    docker build -t $DOCKER_ID/$DOCKER_IMAGE:$DOCKER_TAG ./movie-service
                    sleep 6
                    '''
                }
            }
        }

        stage('Docker Build Cast Service') {
            steps {
                script {
                    sh '''
                    docker rm -f jenkins
                    docker build -t $DOCKER_ID/$DOCKER_IMAGE:$DOCKER_TAG ./cast-service
                    sleep 6
                    '''
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    sh '''
                    docker login -u $DOCKER_ID -p $DOCKER_PASS
                    docker push $DOCKER_ID/$DOCKER_IMAGE:$DOCKER_TAG
                    '''
                }
            }
        }

        stage('Deploiement en dev') {
            steps {
                script {
                    sh '''
                    mkdir -p ~/.kube
                    cp $KUBECONFIG ~/.kube/config
                    cp movie-service/values.yaml values.yml
                    sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                    helm upgrade --install app movie-service --values=values.yml --namespace dev
                    '''
                }
            }
        }

        stage('Deploiement en staging') {
            steps {
                script {
                    sh '''
                    mkdir -p ~/.kube
                    cp $KUBECONFIG ~/.kube/config
                    cp movie-service/values.yaml values.yml
                    sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                    helm upgrade --install app movie-service --values=values.yml --namespace staging
                    '''
                }
            }
        }

        stage('Scan') {
            steps {
                sh 'trivy --severity MEDIUM,HIGH,CRITICAL darinpope/java-web-app:latest'
            }
        }

        stage('Deploiement en qa') {
            steps {
                script {
                    sh '''
                    mkdir -p ~/.kube
                    cp $KUBECONFIG ~/.kube/config
                    cp movie-service/values.yaml values.yml
                    sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                    helm upgrade --install app movie-service --values=values.yml --namespace qa
                    '''
                }
            }
        }

        stage('Deploiement en prod') {
            steps {
                timeout(time: 15, unit: "MINUTES") {
                    input message: 'Do you want to deploy in production ?', ok: 'Yes'
                }
                script {
                    sh '''
                    mkdir -p ~/.kube
                    cp $KUBECONFIG ~/.kube/config
                    cp movie-service/values.yaml values.yml
                    sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                    helm upgrade --install app movie-service --values=values.yml --namespace prod
                    '''
                }
            }
        }
    }
}

