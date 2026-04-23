pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command:
    - cat
    tty: true
"""
        }
    }

    environment {
        AWS_REGION = "eu-west-2"
        ECR_REPO = "562437414591.dkr.ecr.eu-west-2.amazonaws.com/python-api"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Build & Push Image') {
            steps {
                container('kaniko') {
                    sh '''
                    /kaniko/executor \
                      --dockerfile=Dockerfile \
                      --context=. \
                      --destination=$ECR_REPO:$IMAGE_TAG \
                      --destination=$ECR_REPO:latest
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                kubectl set image deployment/python-api \
                python-api=$ECR_REPO:$IMAGE_TAG
                '''
            }
        }
    }
}