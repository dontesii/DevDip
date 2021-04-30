pipeline {
    agent any
    environment {
        imagename = "admon/projectdiplom"
        registryCredential = 'git'
        dockerImage = ''
        CLASS           = "GitSCM"
        BRANCH          = "main"
        GIT_CREDENTIALS = "github-ssh-key"
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
                sh "docker build -f Dockerfile . -t dontesi/projectdiplom:${BUILD_ID}"
                sh "docker login -u dontesi -p${password}"
                sh "docker push dontesi/projectdiplom:${BUILD_ID}"
            }
        }      
       stage("Ansible") {
            steps {
                ansiblePlaybook credentialsId: 'US-Virginia', disableHostKeyChecking: true, installation: 'Ansible', inventory: 'hosts', limit: '100.24.54.233', playbook: 'deploy.yml'  
            }
        }              
    }
}
