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

    buildinfo = []
    def default_properties = [DOCKERFILE: 'Dockerfile', NODE_TYPE:'docker']

    // You have to iterate this way in Jenkins to avoid a marshalling error
    for(int i=0; i<build_configs.size(); i++) {
    filename = build_configs[i]
	props = readProperties defaults: default_properties, file: filename
	buildinfo.add([ props.NODE_TYPE , filename ])
	props = null
    }

    echo "Build configs are: ${build_configs}"
    echo "Build info are: ${buildinfo}"
}

for(int i=0; i<buildinfo.size(); i++) {
    echo "Calling dobuild on ${buildinfo[i]}"
    dobuild(buildinfo[i][0], buildinfo[i][1])
}

def dobuild(label, filename) {

	echo "Building from ${filename} on ${label}"

	    // TODO:  if we can read and pass in the props, we can abstract the node type
	node(label) {
	checkout scm

        def default_properties = [DOCKERFILE: 'Dockerfile', NODE_TYPE:'docker', PUSH_TO:'normal']
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

	imageName=(filename.toString() =~ /\w+\/(.*)\.properties/)[0][1]

	stage("Build ${imageName}") {
		echo "Building command line"
	    def buildargs = props.collect { k, v -> "'${k}=${v}'" }.join(" --build-arg ") 
		echo "Command line is: ${buildargs}"

//	    imageName="${props.VERSION}-${props.RELEASE_BUILD}-${BUILD_NUMBER}"

	    sh "docker build -t ${imageName} -f ${props.DOCKERFILE} --build-arg ${buildargs}  . "

	}

    stage("Push ${imageName}") {

    def tagSet = buildTags(VersionArray)
    def image = docker.image(imageName)

    //////////////////////////////////////////////////////////////////////
    //
    //      The NuoDB (full) docker image can only go to AWS ECR
    //
    //////////////////////////////////////////////////////////////////////
        if(props.VERSION.equals("nuodb")) {
	    if(props.PUSH_TO.equals("redhat")) {
 	      error( "We're not currently pushing full NuoDB built on redhat")
	    }
	    else {
	      sh "docker tag ${imageName} nuodb"
	      standardPush("ECR", "nuodb", env.REPOSITORY, "ecr:${env.region}:${env.awsPushCredentials}", tagSet)
	    }
	}
        else if(props.VERSION.equals("nuodb-ce")) {
	    if(props.PUSH_TO.equals("redhat")) {
 	      sh "docker tag ${imageName} ${env.REDHAT_KEY}/nuodb-ce"
	      standardPush("RedHat", "${env.REDHAT_KEY}/nuodb-ce", env.redhatRepo, env.redhatPushCredentials, tagSet)
	    }
	    else {
 	      sh "docker tag ${imageName} nuodb/nuodb-ce"
 	      standardPush("docker hub", "nuodb/nuodb-ce", "", env.dockerhubPushCredentials, tagSet)
	    }
	}

	    /*
	withCredentials([usernamePassword(credentialsId: 'redhat.subscription', passwordVariable: 'RHPASS', usernameVariable: 'RHUSER')]) {
	   performBuild("nuodb-ce", props, "${env.REDHAT_KEY}/nuodb-ce", "Dockerfile.RHEL")
		}
	    */

    }

}
}
