pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar'
            }
        }   

        stage('Unit Tests - JUnit and Jacoco') {
            steps {
                sh "mvn test"
            }
            post {
              always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
        } 

        stage('Docker Build image and push') {
          steps {
            withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
              sh 'hostname'
              sh 'printenv'
              sh 'docker build -t mrpaulblaise/numeric-app:""${GIT_COMMIT[0..7]}"" .'
              sh 'docker push mrpaulblaise/numeric-app:""${GIT_COMMIT[0..7]}""'
            }
          }
        }
    }
}