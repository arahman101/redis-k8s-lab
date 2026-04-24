pipeline {
    agent any

    environment {
        AWS_REGION = "eu-west-2"
        ECR_REPO = "562437414591.dkr.ecr.eu-west-2.amazonaws.com/python-api"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${ECR_REPO}:${IMAGE_TAG}")
                }
            }
        }

        stage('Install Trivy') {
            steps {
                sh '''
                curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
                '''
            }
        }

        stage('Scan Image') {
            steps {
                sh '''
                ./bin/trivy image ${ECR_REPO}:${IMAGE_TAG} --exit-code 0 --severity HIGH,CRITICAL
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh '''
                    aws ecr get-login-password --region $AWS_REGION \
                    | docker login --username AWS --password-stdin ${ECR_REPO}

                    docker push ${ECR_REPO}:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                kubectl set image deployment/python-api \
                python-api=$ECR_REPO:$IMAGE_TAG
                '''
            }
        }
    }
}