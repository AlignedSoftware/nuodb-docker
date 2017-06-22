//def tag_prefix=env.BRANCH_NAME.replaceAll(/[^a-zA-Z0-9_]/,"_")
// This should really come from branch name

def tag_prefix="master"

def awsPushCredentials=env.AWS_PUSH_CREDENTIALS
def nuodbRepo=env.REPOSITORY
def region="us-east-1"

def dockerhubPushCredentials
def nuodbCERepo

def revision

// On a node which has docker
node('docker') {

    stage('checkout') {
	checkout scm
    }

    //////////////////////////////////////////////////////////////////////
    //
    // Build both the NuoDB (full) image and the NuoDB-CE image
    //
    //////////////////////////////////////////////////////////////////////

    withCredentials([usernamePassword(credentialsId: 'redhat.subscription', passwordVariable: 'RHPASS', usernameVariable: 'RHUSER')]) {
	stage('Build nuodb') {
	    sh "docker build -t nuodb --build-arg RHUSER=${RHUSER} --build-arg RHPASS=${RHPASS} --build-arg VERSION=nuodb ."
	}
	stage('Build nuodb-ce') {
	    sh "docker build -t nuodb-ce --build-arg RHUSER=${RHUSER} --build-arg RHPASS=${RHPASS} --build-arg VERSION=nuodb-ce ."
	}
    }

    //////////////////////////////////////////////////////////////////////
    //
    //      The NuoDB (full) docker image can only go to AWS ECR
    //
    //////////////////////////////////////////////////////////////////////

    def nuodbImage = docker.image("nuodb")
    docker.withRegistry(nuodbRepo, "ecr:${region}:${awsPushCredentials}") {
	stage("Push nuodb") {
	    nuodbImage.push("${tag_prefix}-${BUILD_NUMBER}")
	    nuodbImage.push("${tag_prefix}")

	    if(revision) {
		nuodbImage.push("v${revision}")
	    }

	    if(env.BRANCH_NAME.equals("release")) {
		nuodbImage.push("latest")
	    }
	}
    }

    //////////////////////////////////////////////////////////////////////
    //
    //      The NuoDB-CE image can be pushed to docker hub or to
    //      RedHat repository
    //
    //////////////////////////////////////////////////////////////////////

    def nuodbCEImage = docker.image("nuodb-ce")

    if(dockerhubPushCredentials && nuodbCERepo) {
	docker.withRegistry(nuodbCERepo, dockerhubPushCredentials){
	    stage("Push nuodb-ce") {
		nuodbCEImage.push("${tag_prefix}-${BUILD_NUMBER}")
		nuodbCEImage.push("${tag_prefix}")

		if(revision) {
		    nuodbCEImage.push("${tag_prefix}-${revision}")
		}

		//		if(env.BRANCH_NAME.equals("release")) {
		//		    nuodbCEImage.push("latest")
		//		}
	    }
	}
    }
}
