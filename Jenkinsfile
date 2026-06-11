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
    command: ["cat"]
    tty: true
  - name: docker
    image: docker:latest
    command: ["cat"]
    tty: true
    env:
    - name: DOCKER_HOST
      value: tcp://localhost:2375
  - name: dind
    image: docker:dind
    command: ["dockerd-entrypoint.sh", "--insecure-registry", "host.docker.internal:4000"]
    securityContext:
      privileged: true
    env:
    - name: DOCKER_TLS_CERTDIR
      value: ""
  - name: kubectl
    image: bitnami/kubectl:latest
    command: ["cat"]
    tty: true
'''
        }
    }

    triggers {
        pollSCM('H/2 * * * *')
    }



    stages {

            stage('Fix Permissions') {
    steps {
        // On utilise un conteneur souvent root pour libérer le dossier
        container('docker') {
            sh 'chmod -R 777 /home/jenkins/agent'
        }
    }
}
        stage('Test python') {
            steps {
                container('python') {
                    sh "pip install --user -r requirements.txt"
                    sh "python test.py"
                }
            }
        }

        stage('Build image') {
            steps {
                container('docker') {
                    sh "sleep 5"
                    sh "docker build -t host.docker.internal:4000/pythontest:latest ."
                    sh "docker push host.docker.internal:4000/pythontest:latest"
                }
            }
        }

        stage('Deploy') {
            steps {
                container('kubectl') {
                    sh "kubectl apply -f ./deployment.yaml"
                }
            }
        }
    }
}