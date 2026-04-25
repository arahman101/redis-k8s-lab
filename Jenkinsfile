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

    - name: aws
      image: amazon/aws-cli:2.15.0
      command:
        - sleep
      args:
        - "999999"
      tty: true
      envFrom:
        - secretRef:
            name: aws-creds

    - name: trivy
      image: aquasec/trivy:0.50.0
      command:
        - sleep
      args:
        - "999999"
      tty: true
      envFrom:
        - secretRef:
             name: aws-creds
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
        GITOPS_REPO = "https://github.com/arahman101/gitops-infra.git"
    }

    stages {

        stage('Build & Push Image') {
            steps {
                container('kaniko') {
                    sh '''
                    /kaniko/executor \
                      --dockerfile=$WORKSPACE/Dockerfile \
                      --context=dir://$WORKSPACE \
                      --destination=$ECR_REPO:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Verify Image Exists') {
            steps {
                container('aws') {
                    sh '''
                    aws ecr describe-images \
                    --repository-name python-api \
                    --region eu-west-2 \
                    --image-ids imageTag=$IMAGE_TAG \
                    --verbosity=info
                    '''
                }
            }
        }

        stage('Security Scan (Trivy)') {
            steps {
                container('trivy') {
                    sh '''
                    export AWS_REGION=eu-west-2
                    
                    trivy image \
                    --timeout 10m \
                    --severity HIGH,CRITICAL \
                    --ignore-unfixed \
                    $ECR_REPO:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Tag Latest') {
            steps {
                container('aws'){
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

        stage('Update GitOps Repo') {
            steps {
                sh """
                git clone $GITOPS_REPO gitops
                cd gitops/environments/dev

                sed -i "s/tag:.*/tag: \"$IMAGE_TAG\"/" values.yaml

                git config user.email "jenkins@example.com"
                git config user.name "jenkins"

                git add values.yaml
                git commit -m "Update image tag to $IMAGE_TAG"
                git push
                """
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
    
