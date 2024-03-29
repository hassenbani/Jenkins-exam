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
                // Attendre que les pods soient prêts
                waitForPods(namespace: 'dev', timeout: 180)
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
                // Attendre que les pods soient prêts
                waitForPods(namespace: 'staging', timeout: 180)
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
                // Attendre que les pods soient prêts
                waitForPods(namespace: 'qa', timeout: 180)
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
                // Attendre que les pods soient prêts
                waitForPods(namespace: 'prod', timeout: 180)
            }
        }
    }
}

def waitForPods(Map params) {
    def namespace = params.namespace ?: 'default'
    def timeout = params.timeout ?: 300

    def startTime = currentBuild.startTimeInMillis
    def podCount = sh(script: "kubectl get pods --namespace=${namespace} | grep -E '(Running|Completed)' | wc -l", returnStdout: true).trim().toInteger()

    while (podCount == 0) {
        def currentTime = System.currentTimeMillis()
        def elapsedTime = currentTime - startTime
        if (elapsedTime > timeout * 1000) {
            error "Timeout waiting for pods to be ready"
            break
        }
        sleep 10
        podCount = sh(script: "kubectl get pods --namespace=${namespace} | grep -E '(Running|Completed)' | wc -l", returnStdout: true).trim().toInteger()
    }

    echo "Pods are ready"
}

