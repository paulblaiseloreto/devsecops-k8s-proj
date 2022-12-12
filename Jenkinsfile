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
              withSonarQubeEnv('SonarQube') {
                sh "mvn clean verify sonar:sonar \
                -Dsonar.projectKey=numeric-application \
                -Dsonar.host.url=http://devsecopspaul-demo.eastus.cloudapp.azure.com:9000" 
              }
              timeout(time: 2, unit: 'MINUTES') {
                script {
                  waitForQualityGate abortPipeline: true
                }
              }
          }
        }

       stage('Vulnerability Scan -  Docker') {
         steps {
           parallel (
             "Dependency Scan": {
               sh "mvn dependency-check:check"
             },
             "Trivy Scan":{
               sh "bash trivy-docker-image-scan.sh"
             }
           )
         }
         post {
           always {
             dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
           }
         }
       }

        stage('Docker Build image and push') {
          steps {
              withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
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