/**
  * Plugin evolved: sshAgent, git
  * Password: dockerhub, jenkins_user_ssh_password
  */

node {
    stage('checkout') {
        git credentialsId: 'github-creds', url: 'https://github.com/pyeprog/pd-memo.git'
    }
    stage('build') {
        sh 'docker build --rm -t pyeprog/pd-memo-backend .'
    }
    stage('upload') {
        withCredentials([string(credentialsId: 'dockerhub_password', variable: 'dockerhubpwd')]) {
            sh "docker login -u pyeprog -p ${dockerhubpwd}"
        } 
        sh 'docker push pyeprog/pd-memo-backend'
    }
    stage('deploy') {
        withCredentials([string(credentialsId: 'dockerhub_password', variable: 'jenkinsPassword')]) {
            sshagent(['pd64ssh']) {
                sh "echo ${jenkinsPassword} | sudo -S docker stop pd-memo || true && docker rm pd-memo || true"
                sh "echo ${jenkinsPassword} | sudo -S docker rmi pd-memo-backend:latest || true"
                sh "echo ${jenkinsPassword} | sudo -S docker run --rm -p 8081:8080 -d --name pd-memo pyeprog/pd-memo-backend"
            }
        }
    }
}
