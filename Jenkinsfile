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
    }
}