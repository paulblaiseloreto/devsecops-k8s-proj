pipeline {
  agent any
  environment {
    SHORT_COMMIT = "${GIT_COMMIT[0..7]}"
  }
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
            withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
              sh 'hostname'
              sh 'printenv'
              sh 'docker build -t mrpaulblaise/numeric-app:""$SHORT_COMMIT"" .'
              sh 'docker push mrpaulblaise/numeric-app:""$SHORT_COMMIT""'
            }
        }

        stage('Kubernetes Deployment - DEV') {
          steps {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "sed -i 's#replace#mrpaulblaise/numeric-app:${SHORT_COMMIT}#g' k8s_deployment_service.yaml"
              sh "kubectl apply -f k8s_deployment_service.yaml"
            }
          }
        }


    }
}