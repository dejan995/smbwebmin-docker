pipeline {
  agent any
  stages {
    stage('Cloning Git') {
      parallel {
        stage('Cloning Git') {
          steps {
            checkout scm
          }
        }

        stage('Docker Login') {
          steps {
            withCredentials(bindings: [usernamePassword(credentialsId: 'docker_id', passwordVariable: 'pass', usernameVariable: 'user')]) {
              sh 'docker login -u $user -p $pass'
            }

          }
        }

      }
    }

    stage('Build & Deploy Image') {
      steps {
        sh '''docker buildx build --platform linux/amd64,linux/arm64 \\
                -t dejan995/smbwebmin-docker:$BUILD_NUMBER \\
                -t dejan995/smbwebmin-docker:latest \\
              --push \\
              .'''
      }
    }

  }
  environment {
    registry = 'dejan995/smbwebmin-docker'
    registryCredential = 'docker_id'
    dockerImage = 'dejan995/smbwebmin-docker'
  }
}