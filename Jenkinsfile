//def tag_prefix=env.BRANCH_NAME.replaceAll(/[^a-zA-Z0-9_]/,"_")
// This should really come from branch name

def tag_prefix=""

def awsPushCredentials="build-jenkins-oa"
def nuodbRepo=env.REPOSITORY
def region="us-east-1"

def dockerhubPushCredentials="docker.io-nuodb-push"

def redhatPushCredentials="redhat.nuodb.push"
def redhatRepo="https://registry.rhc4tp.openshift.com"

def suffix=env.SUFFIX

		 

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

def standardPush(label, imageName, tag_prefix, repo, credentials, tags) {

    def image = docker.image(imageName)

    docker.withRegistry(repo, credentials) {
	stage("Push ${imageName} to ${label}") {
	    tags.each {
		echo "docker push ${imageName} ${repo}/${imageName}:${tag_prefix}${it}${suffix}"
		image.push("${tag_prefix}${it}${suffix}")
	    }
	}
    }
}

// On a node which has docker
node() {

    stage('Read Configs') {
	checkout scm
    }

    build_configs = findFiles(glob: 'build-params/*.properties')
    echo "Build configs are: ${build_configs}"

}

for(int i=0; i<build_configs.size(); i++) {
    echo "Calling dobuild on ${build_configs[i]}"
    dobuild(build_configs[i])
}

def dobuild(filename) {

	echo "Building from ${filename}"

	    // TODO:  if we can read and pass in the props, we can abstract the node type
	node("docker && aml") {
	checkout scm

        def default_properties = [DOCKERFILE: 'Dockerfile', NODE_TYPE:'aml']
	def props = readProperties defaults: default_properties, file: filename

    /**  A list of version numbers used to build tags.  See #buildTags for details
     */
	def VersionArray = [ props.RELEASE_BUILD, props.RELEASE_PACKAGE, props.BUILD, env.BUILD_NUMBER]

    //////////////////////////////////////////////////////////////////////
    //
    // Build both the NuoDB (full) image and the NuoDB-CE image
    //
    //////////////////////////////////////////////////////////////////////

	echo "Build stage"

	stage("Build ${props.VERSION} ${props.RELEASE_BUILD}") {
		echo "Building command line"
	    def buildargs = props.collect { k, v -> k + "=" + v }.join(" --build-arg ") 
		echo "Command line is: ${buildargs}"

	    imageName="${props.VERSION}-${props.RELEASE_BUILD}-${BUILD_NUMBER}"

	    sh "docker build -t ${imageName} -f ${props.DOCKERFILE} --build-arg ${buildargs} ."

	}


    if(true) {
	//	performBuild(props.VERSION, props)
    }
    else {
	withCredentials([usernamePassword(credentialsId: 'redhat.subscription', passwordVariable: 'RHPASS', usernameVariable: 'RHUSER')]) {
	    performBuild("nuodb-ce", props, "nuodb/nuodb-ce")
		//	performBuild("nuodb-ce", props, "${env.REDHAT_KEY}/nuodb-ce", "Dockerfile.RHEL")
		}
    }

    //////////////////////////////////////////////////////////////////////
    //
    //      The NuoDB (full) docker image can only go to AWS ECR
    //
    //////////////////////////////////////////////////////////////////////

    def tagSet = buildTags(VersionArray)
	//    standardPush("ECR", "nuodb", tag_prefix, nuodbRepo, "ecr:${region}:${awsPushCredentials}", tagSet)

    //////////////////////////////////////////////////////////////////////
    //
    //      The NuoDB-CE image can be pushed to docker hub and to
    //      RedHat repository
    //
    //////////////////////////////////////////////////////////////////////

	//    standardPush("docker hub", "nuodb/nuodb-ce", tag_prefix, "", dockerhubPushCredentials, tagSet)
//    standardPush("RedHat", "${env.REDHAT_KEY}/nuodb-ce", tag_prefix, redhatRepo, redhatPushCredentials, tagSet)
}
}
