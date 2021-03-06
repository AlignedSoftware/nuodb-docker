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

def standardPush(imageName, repo, credentials, tags) {

    def image = docker.image(imageName)

    // Sometimes a docker push fails due to a server side issue.  Work around docker's issue
    retry (3) {
      docker.withRegistry(repo, credentials) {
            tags.each {
                echo "docker push ${imageName} ${repo}/${imageName}:${it}${suffix}"
                image.push("${it}${suffix}")
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

    buildinfo = []
    def default_properties = [DOCKERFILE: 'Dockerfile', NODE_TYPE:'docker']

    // You have to iterate this way in Jenkins to avoid a marshalling error
    for(int i=0; i<build_configs.size(); i++) {
    filename = build_configs[i]
	props = readProperties defaults: default_properties, file: filename.toString()
	buildinfo.add([ props.NODE_TYPE , filename ])
	props = null
    }

//    echo "Build configs are: ${build_configs}"
    echo "Build info are: ${buildinfo}"
}

builds=[:]

for(int i=0; i<buildinfo.size(); i++) {
    echo "Calling dobuild on ${buildinfo[i]}"
    filename = buildinfo[i][1]
    label = buildinfo[i][0]
    builds[filename]= makebuild(label, filename)
}

def makebuild(label, filename) {
    return {
        dobuild(label, filename)
    }
}

echo "Parallel build: ${params.BUILD_IN_PARALLEL} ${params.BUILD_IN_PARALLEL.getClass()}"

if(!params.BUILD_IN_PARALLEL) {
   builds.each { k, v->
     echo "Calling ${k}"
     v()
   }
}
else {
// Actually perform the builds in parallel
parallel builds
}


def dobuild(nodelabel, filename) {

	echo "Building from ${filename} on ${nodelabel}"

	    // TODO:  if we can read and pass in the props, we can abstract the node type
	node(nodelabel) {
	checkout scm

        def default_properties = [DOCKERFILE: 'Dockerfile', NODE_TYPE:'docker', PUSH_TO:'normal']
	def props = readProperties defaults: default_properties, file: filename.toString()

    /**  A list of version numbers used to build tags.  See #buildTags for details
     */
	def VersionArray = [ props.RELEASE_BUILD, props.RELEASE_PACKAGE, props.BUILD, env.BUILD_NUMBER]

	def fullVersion=VersionArray.join(".")

    //////////////////////////////////////////////////////////////////////
    //
    // Build both the NuoDB (full) image and the NuoDB-CE image
    //
    //////////////////////////////////////////////////////////////////////

	echo "Build stage"

	def imageName=(filename.toString() =~ /\w+\/(.*)\.properties/)[0][1]

	stage("Build ${imageName}") {
	    def buildargs = props.collect { k, v -> "'${k}=${v}'" }.join(" --build-arg ") 
//		echo "Command line is: ${buildargs}"


	    sh "docker build -t ${imageName}:${fullVersion} -f ${props.DOCKERFILE} --build-arg ${buildargs}  . "

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
	      sh "docker tag ${imageName}:${fullVersion} nuodb:${fullVersion}"
	      standardPush("nuodb:${fullVersion}", env.REPOSITORY, "ecr:${env.region}:${env.awsPushCredentials}", tagSet)
	    }
	}
        else if(props.VERSION.equals("nuodb-ce")) {
	    if(props.PUSH_TO.equals("redhat")) {
 	      sh "docker tag ${imageName}:${fullVersion} ${env.REDHAT_KEY}/nuodb-ce:${fullVersion}"
	      standardPush("${env.REDHAT_KEY}/nuodb-ce:${fullVersion}", env.redhatRepo, env.redhatPushCredentials, tagSet)
	    }
	    else {
 	      sh "docker tag ${imageName}:${fullVersion} nuodb/nuodb-ce:${fullVersion}"
 	      standardPush("nuodb/nuodb-ce:${fullVersion}", "", env.dockerhubPushCredentials, tagSet)
	    }
	}
    }

}
}
