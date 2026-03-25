// Configure Jenkins URL automatically
// Sets the URL to http://localhost:8080

import jenkins.model.*

def instance = Jenkins.getInstance()
def config = JenkinsLocationConfiguration.get()
config.setUrl("http://localhost:8080/")
config.save()

println(">>> Jenkins URL set to http://localhost:8080/")
