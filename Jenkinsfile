pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:latest
      args:
        - --dockerfile=Dockerfile
        - --context=dir:///workspace
        - --destination=562437414591.dkr.ecr.eu-west-2.amazonaws.com/python-api:latest
        - --verbosity=info
      volumeMounts:
        - name: docker-config
          mountPath: /kaniko/.docker
  restartPolicy: Never
  volumes:
    - name: docker-config
      secret:
        secretName: ecr-docker-config
'''
        }
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/arahman101/redis-k8s-lab.git'
            }
        }
    }
}