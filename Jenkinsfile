pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:debug
      command:
        - /busybox/sh
      args:
        - -c
        - sleep 999999
      tty: true
      volumeMounts:
        - name: docker-config
          mountPath: /kaniko/.docker
  volumes:
    - name: docker-config
      secret:
        secretName: ecr-docker-config
'''
        }
    }

    environment {
        ECR_REPO = "562437414591.dkr.ecr.eu-west-2.amazonaws.com/python-api"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {

        stage('Build & Push Image') {
            steps {
                container('kaniko') {
                    sh '''
                    /kaniko/executor \
                      --dockerfile=$WORKSPACE/Dockerfile \
                      --context=dir://$WORKSPACE \
                      --destination=$ECR_REPO:$IMAGE_TAG \
                      --verbosity=info
                    '''
                }
            }
        }

        stage('Verify Image Exists (ECR)') {
            steps {
                sh '''
                aws ecr describe-images \
                  --repository-name python-api \
                  --region eu-west-2 \
                  --image-ids imageTag=$IMAGE_TAG
                '''
            }
        }

        stage('Security Scan (Trivy)') {
            steps {
                sh '''
                curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
                ./bin/trivy image $ECR_REPO:$IMAGE_TAG --exit-code 0 --severity HIGH,CRITICAL
                '''
            }
        }

        stage('Tag Latest') {
            steps {
                sh '''
                aws ecr batch-get-image \
                  --repository-name python-api \
                  --image-ids imageTag=$IMAGE_TAG \
                  --region eu-west-2 \
                  --query 'images[].imageManifest' \
                  --output text > manifest.json

                aws ecr put-image \
                  --repository-name python-api \
                  --image-tag latest \
                  --image-manifest file://manifest.json \
                  --region eu-west-2
                '''
            }
        }
    }

    post {
        success {
            echo "Image built and pushed successfully: ${ECR_REPO}:${IMAGE_TAG}"
        }
        failure {
            echo "Pipeline failed"
        }
    }
}
    }
}