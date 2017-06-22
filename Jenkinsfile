//def tag_prefix=env.BRANCH_NAME.replaceAll(/[^a-zA-Z0-9_]/,"_")
// This should really come from branch name

def tag_prefix="master"

def awsPushCredentials=env.AWS_PUSH_CREDENTIALS
def nuodbRepo=env.REPOSITORY
def region="us-east-1"

def dockerhubPushCredentials=env.CE_PUSH_CREDENTIALS
def nuodbCERepo=env.CE_REPOSITORY

/**
 * standardPush -- push the given image to the given repository with
 * all the usuall tags.
 */

def standardPush(imageName, tag_prefix, repo, credentials) {

    def image = docker.image(imageName)
    // This will eventually reference a 'revision' parameter from the environment
    def revision


    docker.withRegistry(repo, credentials) {
	stage("Push ${imageName}") {
	    image.push("${tag_prefix}-${BUILD_NUMBER}")
	    image.push("${tag_prefix}")

	    if(revision) {
		image.push("v${revision}")
	    }

	    if(env.BRANCH_NAME.equals("release")) {
		image.push("latest")
	    }
	}
    }
}

def performBuild(image) {
	stage("Build ${image}") {
	    sh "docker build -t ${image} --build-arg RHUSER=${RHUSER} --build-arg RHPASS=${RHPASS} --build-arg VERSION=${image} ."
	}
}

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
	performBuild("nuodb")
	performBuild("nuodb-ce")
    }

    //////////////////////////////////////////////////////////////////////
    //
    //      The NuoDB (full) docker image can only go to AWS ECR
    //
    //////////////////////////////////////////////////////////////////////

    standardPush("nuodb", tag_prefix, nuodbRepo, "ecr:${region}:${awsPushCredentials}")

    //////////////////////////////////////////////////////////////////////
    //
    //      The NuoDB-CE image can be pushed to docker hub or to
    //      RedHat repository
    //
    //////////////////////////////////////////////////////////////////////

    if(dockerhubPushCredentials!=null && !dockerhubPushCredentials?.trim().equals("")) {
	standardPush("nuodb-ce", tag_prefix, nuodbCERepo, dockerhubPushCredentials)
    }
}
