pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    component: ci
spec:
  containers:
  - name: python
    image: python:3.7
    command: ['cat']
    tty: true
    volumeMounts:
    - mountPath: /home/jenkins/agent
      name: workspace-volume
  - name: docker
    image: docker:latest
    command: ['cat']
    tty: true
    env:
    - name: DOCKER_HOST
      value: tcp://localhost:2375
    volumeMounts:
    - mountPath: /home/jenkins/agent
      name: workspace-volume
  - name: dind
    image: docker:dind
    command: ["dockerd-entrypoint.sh", "--insecure-registry", "host.docker.internal:4000"]
    privileged: true # Changement ici : direct sous le conteneur si nécessaire selon la version de k8s, ou dans securityContext
    securityContext:
        privileged: true
    env:
    - name: DOCKER_TLS_CERTDIR
      value: ""
    volumeMounts: # <-- AJOUT CRUCIAL : dind doit aussi voir le workspace pour les montages de fichiers
    - mountPath: /home/jenkins/agent
      name: workspace-volume
  - name: kubectl
    image: bitnami/kubectl:latest
    command: ['cat']
    tty: true
    volumeMounts:
    - mountPath: /home/jenkins/agent
      name: workspace-volume
  volumes:
  - name: workspace-volume
    emptyDir: {}
'''
        }
    }

    triggers {
        pollSCM('H/2 * * * *')
    }

    stages {
        stage('Test python') {
            steps {
                container('python') {
                    echo '--- ÉTAPE 1 : Validation des Tests Unitaires ---'
                    // Forcer l'utilisation du dossier courant pour éviter les conflits de droits globaux
                    sh "pip install --user -r requirements.txt"
                    sh "python test.py"
                }
            }
        }

        stage('Test Shell Diagnostics') {
            steps {
                // Ta commande de test, bien au chaud dans le workspace virtuel emptyDir
                sh 'echo "Test execution shell OK !"'
            }
        }

        stage('Build image') {
            steps {
                container('docker') {
                    echo '--- ÉTAPE 2 : Build & Push vers le Registre Local ---'
                    sh "sleep 5" 
                    sh "docker build -t host.docker.internal:4000/pythontest:latest ."
                    sh "docker push host.docker.internal:4000/pythontest:latest"
                }
            }
        }

        stage('Deploy') {
            steps {
                container('kubectl') {
                    echo '--- ÉTAPE 3 : Déploiement Unique de l\'Application ---'
                    sh "kubectl apply -f ./deployment.yaml"
                }
            }
        }
    }
}