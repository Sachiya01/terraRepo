#!/bin/bash
set -e

# Log everything
exec > /var/log/user-data.log 2>&1

echo "Starting Jenkins setup..."

# Update system
apt update -y

# Install Java
apt install -y openjdk-21-jdk

# Create keyrings directory
mkdir -p /etc/apt/keyrings

# Add Jenkins GPG key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key \
  | tee /etc/apt/keyrings/jenkins-keyring.asc > /dev/null

# Add Jenkins repository (THIS WAS MISSING / WRONG)
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" \
> /etc/apt/sources.list.d/jenkins.list

# Update again so Jenkins appears
apt update -y

# Install Jenkins
apt install -y jenkins

# Enable and start Jenkins
systemctl enable jenkins

mkdir -p /var/lib/jenkins/init.groovy.d

cat <<'EOF' > /var/lib/jenkins/init.groovy.d/basic-security.groovy
#!groovy

import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

// Create admin user
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "admin123")
instance.setSecurityRealm(hudsonRealm)

// Grant admin permissions
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.save()
EOF

chown -R jenkins:jenkins /var/lib/jenkins/init.groovy.d


systemctl start jenkins
systemctl restart jenkins
# Wait for Jenkins to be ready
sleep 60

# Install Job DSL plugin
JENKINS_CLI=/tmp/jenkins-cli.jar
wget http://localhost:8080/jnlpJars/jenkins-cli.jar -O $JENKINS_CLI

# Disable setup wizard
echo "JAVA_ARGS=\"-Djenkins.install.runSetupWizard=false\"" \
>> /etc/default/jenkins
systemctl restart jenkins
sleep 30

# Install required plugins
java -jar $JENKINS_CLI \
  -s http://localhost:8080 \
  -auth admin:admin123 \
  install-plugin workflow-aggregator job-dsl git pipeline-github-lib -restart



cat <<EOF > /tmp/seed-job.xml
<project>
  <builders>
    <javaposse.jobdsl.plugin.ExecuteDslScripts>
      <scriptText>
pipelineJob('my-declarative-pipeline') {
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/Sachiya01/terraRepo.git')
                    }
                    branches('*/main')
                }
            }
            scriptPath('Jenkinsfile')
        }
    }
}
      </scriptText>
    </javaposse.jobdsl.plugin.ExecuteDslScripts>
  </builders>
</project>
EOF

java -jar $JENKINS_CLI \
  -s http://localhost:8080 \
  -auth admin:admin123 \
  create-job seed-job < /tmp/seed-job.xml
