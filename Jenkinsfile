pipeline {
    environment { // Déclaration des variables d'environnement
        DOCKER_ID = "hasaron" // Remplacer par votre docker-id
        DOCKER_IMAGE = "datascientestapi"
        DOCKER_TAG = "v.${BUILD_ID}.0" // Nous étiquetterons nos images avec la construction actuelle pour incrémenter la valeur à chaque nouvelle construction
    }
    agent any // Jenkins sera en mesure de sélectionner tous les agents disponibles
    stages {
        stage('Construction Docker'){ // Étape de construction de l'image Docker
            steps {
                script {
                    sh "docker rm -f jenkins"
                    sh "docker build -t $DOCKER_ID/$DOCKER_IMAGE:$DOCKER_TAG ."
                    sleep 6
                }
            }
        }
        stage('Docker run'){ // Exécution du conteneur à partir de notre image construite
            steps {
                script {
                    sh "docker run -d -p 80:80 --name jenkins $DOCKER_ID/$DOCKER_IMAGE:$DOCKER_TAG"
                    sleep 10
                }
            }
        }
        stage('Test Acceptance'){ // Nous lançons la commande curl pour vérifier que le conteneur répond à la requête
            steps {
                script {
                    sh "curl localhost"
                }
            }
        }
        stage('Docker Push'){ // Nous passons l'image construite à notre compte Docker Hub
            environment {
                DOCKER_PASS = credentials("DOCKER_HUB_PASS") // Nous récupérons le mot de passe Docker depuis le texte secret appelé DOCKER_HUB_PASS sauvegardé sur Jenkins
            }
            steps {
                script {
                    sh "docker login -u $DOCKER_ID -p $DOCKER_PASS"
                    sh "docker push $DOCKER_ID/$DOCKER_IMAGE:$DOCKER_TAG"
                }
            }
        }
        stage('Déploiement en dev'){ // Déploiement sur l'environnement de développement
            environment {
                KUBECONFIG = credentials("config") // Nous récupérons le kubeconfig depuis le fichier secret appelé config sauvegardé sur Jenkins
            }
            steps {
                script {
                    sh '''
                    rm -Rf .kube
                    mkdir .kube
                    cat $KUBECONFIG > .kube/config
                    cp movie-service/templates/values.yaml values.yaml
                    sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yaml
                    helm upgrade --install app movie-service --values=values.yaml --namespace dev
                    '''
                }
            }
        }
        stage('Déploiement en staging'){ // Déploiement sur l'environnement de staging
            environment {
                KUBECONFIG = credentials("config") // Nous récupérons le kubeconfig depuis le fichier secret appelé config sauvegardé sur Jenkins
            }
            steps {
                script {
                    sh '''
                    rm -Rf .kube
                    mkdir .kube
                    cat $KUBECONFIG > .kube/config
                    cp movie-service/templates/values.yaml values.yaml
                    sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yaml
                    helm upgrade --install app movie-service --values=values.yaml --namespace staging
                    '''
                }
            }
        }
        stage('Déploiement en qa'){ // Déploiement sur l'environnement de QA
            environment {
                KUBECONFIG = credentials("config") // Nous récupérons le kubeconfig depuis le fichier secret appelé config sauvegardé sur Jenkins
            }
            steps {
                script {
                    sh '''
                    rm -Rf .kube
                    mkdir .kube
                    cat $KUBECONFIG > .kube/config
                    cp movie-service/templates/values.yaml values.yaml
                    sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yaml
                    helm upgrade --install app movie-service --values=values.yaml --namespace qa
                    '''
                }
            }
        }
        stage('Déploiement en prod'){ // Déploiement sur l'environnement de production
            when {
                branch 'master' // Déploiement uniquement lorsque la branche est la branche Master
            }
            environment {
                KUBECONFIG = credentials("config") // Nous récupérons le kubeconfig depuis le fichier secret appelé config sauvegardé sur Jenkins
            }
            steps {
                timeout(time: 15, unit: "MINUTES") { // Créer un bouton d'approbation avec un délai de 15 minutes
                    input message: 'Do you want to deploy in production ?', ok: 'Yes'
                }
                script {
                    sh '''
                    rm -Rf .kube
                    mkdir .kube
                    cat $KUBECONFIG > .kube/config
                    cp movie-service/templates/values.yaml values.yaml
                    sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yaml
                    helm upgrade --install app movie-service --values=values.yaml --namespace prod
                    '''
                }
            }
        }
    }
}

