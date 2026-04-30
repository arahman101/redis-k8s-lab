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
        parameters {
        booleanParam(
            name: 'PROMOTE',
            defaultValue: false,
            description: 'Promote this build to production'
        )
    }

    environment {
        ECR_REPO = "562437414591.dkr.ecr.eu-west-2.amazonaws.com/python-api"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        GITOPS_REPO = "https://github.com/arahman101/gitops-infra.git"
    }

    stages {

        stage('Prepare Workspace') {
            steps {
                deleteDir()
                checkout scm
            }
        }

    stage('Build & Scan') {
        parallel {           

            stage('Build & Push Image') {
                steps {
                    container('kaniko') {
                        sh '''
                        /kaniko/executor \
                        --dockerfile=$WORKSPACE/Dockerfile \
                        --context=dir://$WORKSPACE \
                        --destination=$ECR_REPO:$IMAGE_TAG \
                        --cache=true \
                        --cache-repo=$ECR_REPO/cache \
                        --cache-copy-layers \
                        --verbosity=info
                        '''
                    }
                }
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
                    --image-tag prod-latest \
                    --image-manifest file://manifest.json \
                    --region eu-west-2
                    '''
                }
            }
        }

        stage('Update GitOps Repo') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'git-creds',
                    usernameVariable: 'GIT_USER',
                    passwordVariable: 'GIT_PASS'
                )]) {

                    sh '''
                    rm -rf gitops-* || true

                    # Securely configure git credentials
                    cat > ~/.netrc <<EOF
                    machine github.com
                    login $GIT_USER
                    password $GIT_PASS
                    EOF

                    chmod 600 ~/.netrc

                    # Clone the repository
                    git clone --depth 1 https://github.com/arahman101/gitops-infra.git gitops-$BUILD_NUMBER

                    # Navigate to the Helm chart directory
                    cd gitops-$BUILD_NUMBER/helm/redis-app

                    # Target the dev specific values file
                    sed -i "s/tag:.*/tag: \\"$IMAGE_TAG\\"/" values-dev.yaml

                    git config user.email "artariq2001@gmail.com"
                    git config user.name "arahman101"

                    # Add and commit the dev file
                    git add values-dev.yaml
                    git diff --quiet || git commit -m "Update dev image tag to $IMAGE_TAG"

                    git push
                    '''
                }
            }
        }

        
        stage('Promote to Prod') {
            when {
                expression { return params.PROMOTE == true }
            }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'git-creds',
                    usernameVariable: 'GIT_USER',
                    passwordVariable: 'GIT_PASS'
                )]) {

                    sh '''
                    rm -rf gitops-prod-* || true

                    # Securely configure git credentials
                    cat > ~/.netrc <<EOF
                    machine github.com
                    login $GIT_USER
                    password $GIT_PASS
                    EOF
                    
                    chmod 600 ~/.netrc

                    # Clone fresh for prod to avoid conflicts with the dev workspace
                    git clone --depth 1 https://github.com/arahman101/gitops-infra.git gitops-prod-$BUILD_NUMBER
                    
                    # Navigate to the Helm chart directory
                    cd gitops-prod-$BUILD_NUMBER/helm/redis-app

                    # Target the prod specific values file
                    sed -i "s/tag:.*/tag: \\"$IMAGE_TAG\\"/" values-prod.yaml

                    git config user.email "artariq2001@gmail.com"
                    git config user.name "arahman101"

                    # Add and commit the prod file
                    git add values-prod.yaml
                    git diff --quiet || git commit -m "Promote image $IMAGE_TAG to prod"

                    git push
                    '''
                }   
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
    
