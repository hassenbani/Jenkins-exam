pipeline {
    agent any

    stages {
        stage('Declarative: Checkout SCM') {
            steps {
                checkout scm
            }
        }
        stage('Docker Build') {
            steps {
                sh 'docker build -t hasaron/datascientestapi:v.35.0 ./cast-service'
            }
        }
        stage('Docker Run') {
            steps {
                sh 'docker run -d -p 80:80 --name jenkins hasaron/datascientestapi:v.35.0'
                sleep 10
            }
        }
        stage('Test Acceptance') {
            steps {
                sh 'curl localhost'
            }
        }
        stage('Docker Push') {
            environment {
                DOCKER_PASS = credentials('docker-hub-pass')
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh '''
                        docker login -u $DOCKER_USER -p $DOCKER_PASS
                        docker push hasaron/datascientestapi:v.35.0
                    '''
                }
            }
        }
        stage('Deploiement en dev') {
            steps {
                script {
                    sh '''
                        cp cast-service/values.yaml values.yml
                        sed -i 's+tag.*+tag: v.35.0+g' values.yml
                        chmod +r /home/ubuntu/.kube/config
                        helm upgrade --install app cast-service --values=values.yml --namespace dev
                    '''
                }
            }
        }
    }
}

