pipeline {
    agent any
    environment {
        imagename             = "admon/projectdiplom"
        registryCredential    = 'git'
        dockerImage           = ''
        CLASS                 = "GitSCM"
        BRANCH                = "main"
        GIT_CREDENTIALS       = "github-ssh-key"
        GIT_URL               = "git@github.com:dontesii/ProdDip.git"
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
     }
    stages {
      stage('Notification on Slack Start') {
            steps {
                slackSend channel: '#testadmon', message: 'Job Start', blocks: [
                    [
                      "type": "section",
                      "text": [
                        "type": "mrkdwn",
                        "text": "*Run configure*"
                      ]
                    ],
                    [
                      "type": "section",
                      "text": [
                        "type": "mrkdwn",
                        "text": "Start Checkout SCM, Prepare build image"
                      ]
                     ]
                    ]
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
        
          stage('Notification on Slack Comleted build/push image') {
            steps {
                slackSend channel: '#testadmon', message: 'Job processed', blocks: [
                    [
                      "type": "section",
                      "text": [
                        "type": "mrkdwn",
                        "text": "*Image pushed*"
                      ]
                    ],
                    [
                      "type": "section",
                      "text": [
                        "type": "mrkdwn",
                        "text": "Image on DockerHub"
                      ]
                     ]
                    ]
               }
             }
       stage('Notification on Slack start ec2.py and run Ansible-playbook') {
            steps {
                slackSend channel: '#testadmon', message: 'Job processed', blocks: [
                    [
                      "type": "section",
                      "text": [
                        "type": "mrkdwn",
                        "text": "*start ec2.py and run Ansible-playbook*"
                      ]
                    ],
                    [
                      "type": "section",
                      "text": [
                        "type": "mrkdwn",
                        "text": "Run dynamic inventory, generate file host for ansible playbook and run deploy"
                      ]
                     ]
                    ]
               }
             }
       stage("run ec2.py") {
            steps {
                sh "chmod +x ec2.py"
                sh "pwd"
                sh "./ec2.py --list"
               
            }
        } 
       stage("Ansible") {
            steps {
               ansiblePlaybook become: true, becomeUser: 'root', credentialsId: 'keyAWS', disableHostKeyChecking: true, installation: 'Ansible', inventory: 'ec2.py', playbook: 'deploy.yml'
            }              
          }
        
       stage('Notification on Slack finish Job') {
            steps {
                slackSend channel: '#testadmon', message: 'Job finish', blocks: [
                    [
                      "type": "section",
                      "text": [
                        "type": "mrkdwn",
                        "text": "*Deploy completed*"
                      ]
                    ],
                    [
                      "type": "section",
                      "text": [
                        "type": "mrkdwn",
                        "text": "Finish"
                      ]
                     ]
                    ]
               }
             }
    }
}
     //  stage("Ansible") {
       //     steps {
         //       ansiblePlaybook becomeUser: 'ubuntu', credentialsId: 'US-Virginia', disableHostKeyChecking: true, installation: 'Ansible', inventory: 'hosts', playbook: 'deploy.yml'
           // }
        //}              

