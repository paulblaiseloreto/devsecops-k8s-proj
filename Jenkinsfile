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

        stage('SonarQube - SAST') {
          steps {
                sh "mvn clean verify sonar:sonar \
                -Dsonar.projectKey=numeric-application \
                -Dsonar.host.url=http://devsecopspaul-demo.eastus.cloudapp.azure.com:9000 \
                -Dsonar.login=sqp_1f640b419f08e8bc082cce09bc40a2f603576548"
            }
        }

        stage('Docker Build image and push') {
          steps {
              withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
                sh 'echo ${STAGE_NAME}'
                sh 'printenv'
                sh 'docker build -t mrpaulblaise/numeric-app:""$SHORT_COMMIT"" .'
                sh 'docker push mrpaulblaise/numeric-app:""$SHORT_COMMIT""'
                } 
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
    
def test () {
  stage ('Forced Success') {
      echo "Force Success!"
  }
}