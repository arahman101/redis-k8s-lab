pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest  # Correct Kaniko Executor image
    command:
    - "/kaniko/executor"  # Correct command to run Kaniko directly
    args:
    - "--dockerfile=Dockerfile"
    - "--context=."
    - "--destination=\${ECR_REPO}:\${IMAGE_TAG}"
    - "--destination=\${ECR_REPO}:latest"
    env:
    - name: AWS_REGION
      value: "eu-west-2"
    - name: ECR_REPO
      value: "562437414591.dkr.ecr.eu-west-2.amazonaws.com/python-api"
    - name: IMAGE_TAG
      value: "${BUILD_NUMBER}"
    volumeMounts:
    - mountPath: "/home/jenkins/agent"
      name: workspace-volume
  restartPolicy: Never
  volumes:
  - emptyDir: {}
    name: workspace-volume
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