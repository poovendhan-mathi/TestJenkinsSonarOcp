// Create default admin user for Jenkins
// This runs automatically on first startup

import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

// Only create user if no users exist yet
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
if (hudsonRealm.getAllUsers().size() == 0) {
    hudsonRealm.createAccount("admin", "admin123")
    instance.setSecurityRealm(hudsonRealm)

    def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
    strategy.setAllowAnonymousRead(false)
    instance.setAuthorizationStrategy(strategy)

    instance.save()
    println(">>> Default admin user created (admin / admin123)")
} else {
    println(">>> Users already exist, skipping admin creation")
}
