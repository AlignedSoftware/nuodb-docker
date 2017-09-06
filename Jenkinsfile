//def tag_prefix=env.BRANCH_NAME.replaceAll(/[^a-zA-Z0-9_]/,"_")
// This should really come from branch name

env.awsPushCredentials="build-jenkins-oa"
env.region="us-east-1"

env.dockerhubPushCredentials="docker.io-nuodb-push"

env.redhatPushCredentials="redhat.nuodb.push"
env.redhatRepo="https://registry.rhc4tp.openshift.com"

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

def standardPush(label, imageName, repo, credentials, tags) {

    def image = docker.image(imageName)

    docker.withRegistry(repo, credentials) {
            tags.each {
                echo "docker push ${imageName} ${repo}/${imageName}:${it}${suffix}"
                image.push("${it}${suffix}")
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

    stage("Push ${props.VERSION} ${props.RELEASE_BUILD}") {

    def tagSet = buildTags(VersionArray)
    def image = docker.image(imageName)

    //////////////////////////////////////////////////////////////////////
    //
    //      The NuoDB (full) docker image can only go to AWS ECR
    //
    //////////////////////////////////////////////////////////////////////
        if(props.VERSION.equals("nuodb")) {
	    sh "docker tag ${imageName} nuodb"
	    standardPush("ECR", "nuodb", env.REPOSITORY, "ecr:${env.region}:${env.awsPushCredentials}", tagSet)
	}
        else if(props.VERSION.equals("nuodb-ce")) {
	    sh "docker tag ${imageName} nuodb/nuodb-ce"
	    standardPush("docker hub", "nuodb/nuodb-ce", "", env.dockerhubPushCredentials, tagSet)
	}

	    /*
	withCredentials([usernamePassword(credentialsId: 'redhat.subscription', passwordVariable: 'RHPASS', usernameVariable: 'RHUSER')]) {
	   performBuild("nuodb-ce", props, "${env.REDHAT_KEY}/nuodb-ce", "Dockerfile.RHEL")
		}
	    */

    }

}
}
