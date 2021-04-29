pipeline {
    agent any
    environment {
        imagename = "jekanik/projectfordiplom"
        registryCredential = 'git'
        dockerImage = ''
        CLASS           = "GitSCM"
        BRANCH          = "main"
        GIT_CREDENTIALS = "git-hubsshkey"
        GIT_URL         = "git@github.com:dontesii/ProdDip.git"
    }
    stages {
        stage('Proj') {
            steps {
                echo 'Run, Go!'
            }
        }
      stage('Checkout SCM') {
            steps {
                checkout([
                    $class: "${CLASS}",
                    branches: [[name: "${BRANCH}"]],
                    userRemoteConfigs: [[
                    url: "${GIT_URL}",
                    credentialsId: "${GIT_CREDENTIALS}",
                    ]]
                ])
            }
        }
       stage("Prepare build image") {
            steps {
                sh "docker build -f Dockerfile . -t admon/projectdiplom:${BUILD_ID}"
                sh "docker login -u jekanik -p${password}"
                sh "docker push admon/projectdiplom:${BUILD_ID}"
            }
        }      
       stage("Ansible") {
            steps {
                ansiblePlaybook credentialsId: 'd2413b3b-07e6-4a40-842b-f15e1d6ed3e5', disableHostKeyChecking: true, installation: 'Ansible', inventory: 'hosts', playbook: 'deploy.yml'
            }
        }              
    }
}
