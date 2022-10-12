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
          steps {
            script {
                try {
                  deploytoDockerReg()
              } finally {
                stage('mimic work scripted pipeline') {
                  test()         
                }
              } 
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

def deploytoDockerReg () {
  script {
      try {
      stage ('Deploy to Docker') {
        steps {
          script {
              withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
                sh 'echo ${STAGE_NAME}'
                sh 'printenv'
                sh 'docker build -t mrpaulblaise/numeric-app:""$SHORT_COMMIT"" .'
                sh 'docker push mrpaulblaise/numeric-ap:""$SHORT_COMMIT""'
              }     
            } 
          }
        }
    } catch (err) {
        unstable(message: "${STAGE_NAME} is unstable")
        throw err
    }
  }
  
} 

    
def test () {
      echo "Force Success!"
    }