//def tag_prefix=env.BRANCH_NAME.replaceAll(/[^a-zA-Z0-9_]/,"_")
// This should really come from branch name

def tag_prefix="dms-"

def awsPushCredentials="build-jenkins-aws"
def nuodbRepo=env.REPOSITORY
def region="us-east-1"

def dockerhubPushCredentials="docker.io-nuodb-push"
def nuodbCERepo=env.CE_REPOSITORY

def redhatPushCredentials="redhat.subscription"
def redhatRepo=env.REDHAT_REPOSITORY

def release_build=env.RELEASE_BUILD
def release_package=env.RELEASE_PACKAGE
def build=env.RELEASE_BUILD_NUMBER

    // A map of build arguments that will be passed to docker
def BUILDARGS = [ "RELEASE_BUILD": release_build,
		  "RELEASE_PACKAGE": release_package,
		  "BUILD": build,
		  ]
    /**  A list of version numbers used to build tags.  See #buildTags for details
     */
def VersionArray = [ release_build, release_package, build, env.BUILD_NUMBER]
		 

    /** Build a list of tags from an array of version numbers.
     *
     * The array is built by concatenating as follows: (1,2,3) becomes
     * ("1", "1.2", "1.2.3")
     *
     */

def buildTags(array) {
    def strings=[]
    def last
    array.each { s->
	       if(last) {
		   last = last + "-" + s
	       }
	       else {
		   last = s
	       }
	       strings << last
    }

    return strings.reverse()
}


/**
 * standardPush -- push the given image to the given repository with
 * all the usuall tags.
 */

def standardPush(imageName, tag_prefix, repo, credentials, tags) {

    def image = docker.image(imageName)

	//    if(tag_prefix) {
	//	tags = tags.collect { "" + tag_prefix + "-" + it }
	//    }

    docker.withRegistry(repo, credentials) {
	stage("Push ${imageName}") {
	    tags.each {
		echo "docker push ${imageName} ${repo}/${imageName}:${tag_prefix}${it}"
	    }

	    // image.push("${tag_prefix}-${BUILD_NUMBER}")
	    // image.push("${tag_prefix}")

	    // if(revision) {
	    // 	image.push("v${revision}")
	    // }

	    // if(env.BRANCH_NAME.equals("release")) {
	    // 	image.push("latest")
	    // }
	}
    }
}

/** Perform the actual build, with full build arguments
 */
def performBuild(image, args) {
	stage("Build ${image}") {
	    def arglist = []
	    args.each { k, v ->
		    arglist << k + "=" + v }
	    def buildargs = arglist.join(" --build-arg ")

	    sh "docker build -t ${image} --build-arg RHUSER=${RHUSER} --build-arg RHPASS=${RHPASS} --build-arg VERSION=${image} --build-arg ${buildargs} ."
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
	performBuild("nuodb", BUILDARGS)
	performBuild("nuodb-ce", BUILDARGS)
    }

    //////////////////////////////////////////////////////////////////////
    //
    //      The NuoDB (full) docker image can only go to AWS ECR
    //
    //////////////////////////////////////////////////////////////////////

    def tagSet = buildTags(VersionArray)
    standardPush("nuodb", tag_prefix, nuodbRepo, "ecr:${region}:${awsPushCredentials}", tagSet)

    //////////////////////////////////////////////////////////////////////
    //
    //      The NuoDB-CE image can be pushed to docker hub or to
    //      RedHat repository
    //
    //////////////////////////////////////////////////////////////////////

    if(dockerhubPushCredentials!=null && !dockerhubPushCredentials?.trim().equals("")) {
	standardPush("nuodb-ce", tag_prefix, nuodbCERepo, dockerhubPushCredentials, tagSet)
    }
}
