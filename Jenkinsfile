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
                    sh '''
                    docker rm -f jenkins
                    docker build -t $DOCKER_ID/$DOCKER_IMAGE:$DOCKER_TAG ./cast-service
                    sleep 6
                    '''
                }
            }
        }
        stage('Docker run') {
            steps {
                script {
                    sh '''
                    docker run -d -p 80:80 --name jenkins $DOCKER_ID/$DOCKER_IMAGE:$DOCKER_TAG
                    sleep 10
                    '''
                }
            }
        }
        stage('Test Acceptance') {
            steps {
                script {
                    sh '''
                    curl localhost
                    '''
                }
            }
        }
        stage('Docker Push') {
            environment {
                DOCKER_PASS = credentials("DOCKER_HUB_PASS")
            }
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
            environment {
                KUBECONFIG = "/home/ubuntu/.kube/config"
            }
            steps {
                script {
                    sh '''
                    cp cast-service/values.yaml values.yml
                    sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                    helm upgrade --install app cast-service --values=values.yml --namespace dev
                    '''
                }
            }
        }
        stage('Deploiement en staging') {
            environment {
                KUBECONFIG = "/home/ubuntu/.kube/config"
            }
            steps {
                script {
                    sh '''
                    cp cast-service/values.yaml values.yml
                    sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                    helm upgrade --install app cast-service --values=values.yml --namespace staging
                    '''
                }
            }
        }
        stage('Deploiement en qa') {
            environment {
                KUBECONFIG = "/home/ubuntu/.kube/config"
            }
            steps {
                script {
                    sh '''
                    cp cast-service/values.yaml values.yml
                    sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                    helm upgrade --install app cast-service --values=values.yml --namespace qa
                    '''
                }
            }
        }
        stage('Deploiement en prod') {
            environment {
                KUBECONFIG = "/home/ubuntu/.kube/config"
            }
            steps {
                timeout(time: 15, unit: "MINUTES") {
                    input message: 'Do you want to deploy in production ?', ok: 'Yes'
                }
                script {
                    sh '''
                    cp cast-service/values.yaml values.yml
                    sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                    helm upgrade --install app cast-service --values=values.yml --namespace prod
                    '''
                }
            }
        }
    }
}

