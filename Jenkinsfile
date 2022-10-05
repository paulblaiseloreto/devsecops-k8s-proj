pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar'
            }
        }   

        stage('Unit Tests') {
            steps {
              sh {
                sh "mvn test"
              }
            }
        } 
    }
}