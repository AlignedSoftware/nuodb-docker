//def tag_prefix=env.BRANCH_NAME.replaceAll(/[^a-zA-Z0-9_]/,"_")
// This should really come from branch name

def tag_prefix="master"
def pushCredentials="build-jenkins-oa"
def region="us-east-1"
def repo=env.REPOSITORY

// On a node which has docker
node('docker') {
  def i

  stage('checkout') {
      checkout scm
  }

  withCredentials([usernamePassword(credentialsId: 'redhat.subscription', passwordVariable: 'RHPASS', usernameVariable: 'RHUSER')]) {
    stage('Docker build') {
	sh "ls"
	sh "docker build -t nuodb --build-arg RHUSER=${RHUSER} --build-arg RHPASS=${RHPASS} --build-arg VERSION=nuodb ."
    }
  }

  // The above build arguments seem to confuse the Pipeline, so just look up the image separately
  i = docker.image("nuodb")
  docker.withRegistry(repo, "ecr:${region}:${pushCredentials}") {
    i.push("${tag_prefix}-${BUILD_NUMBER}")
    i.push("${tag_prefix}")

    if(env.BRANCH_NAME.equals("release")) {
      i.push("latest")
    }
  }
}