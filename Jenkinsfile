pipeline {
    agent any

    environment {
        // ANSI Color Code
        RESET_COLOR = '\033[0m'
        RED = '\033[31m'
        GREEN = '\033[032m'
        BLUE = '\033[034m'
        YELLOW = '\033[033m'
        PURPLE = '\033[035m'

        // Project info
        APP_NAME = "jso-blog"
        RELEASE = "1.0.0"
        GITHUB_URL = "https://github.com/fleeforezz/Jso_Blog.git"

        // Sonar Scanner info
        SCANNER_HOME=tool 'sonar-server'
        SONAR_HOST_URL = "https://sonarqube.fleeforezz.me"

        // Docker info
        REGISTRY = "gitea.fleeforezz.me"
        DOCKER_USER = "jso"
        IMAGE_NAME = "${REGISTRY}" + "/" + "${DOCKER_USER}" + "/" + "${APP_NAME}"
        IMAGE_RELEASE_TAG = "${RELEASE}-${BUILD_NUMBER}"
        IMAGE_LATEST_TAG = "latest"
        IMAGE_BETA_TAG = "beta"

        // Server info
        // SERVER_USERNAME = "nhat"
        // SERVER_IP = "10.0.1.32"
        // SERVER_CONNECTION = "${SERVER_USERNAME}" + " " + "${SERVER_IP}"
    }

    stages {
        stage('Clean up WorkSpace') {
            steps {
                echo "####################### ${RED}Clean up WorkSpace${RESET_COLOR} #######################"
                cleanWs()
            }
        }

        stage('Git Checkout') {
            steps {
                echo "####################### Git Checkout #######################"
                git branch: 'main', url: "${GITHUB_URL}"
            }
        }


        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    echo "####################### ${BLUE}Sonar Scan${RESET_COLOR} #######################"
                    sh "$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectKey=Jso-blog -Dsonar.projectKey=Jso-blog -Dsonar.host.url=${SONAR_HOST_URL}"
                }
            }
        }
        
        stage('Ruby Build') {
            steps {
                echo "####################### ${RED}Ruby Build${RESET_COLOR} #######################"
                sh "sudo gem install bundler"
                sh "sudo bundle install"
                sh "sudo bundle exec jekyll b"
            }
        }
        
        stage('Ruby Test') {
            steps {
                echo "####################### ${RED}Ruby Test${RESET_COLOR} #######################"
                sh "sudo bundle exec jekyll build -d test"
            }
        }

        stage('OWASP DP-SCAN') {
            steps {
                dependencyCheck additionalArguments: '', nvdCredentialsId: 'NVD-API', odcInstallation: 'owasp-dp-check'
            }
        }

        stage('Trivy Filesystem Scan') {
            steps {
                echo "####################### ${YELLOW}Trivy Filesystem Scan${RESET_COLOR} #######################"
                sh "trivy fs . > trivyfs.txt"
            }
        }

        stage('Docker Build') {
            steps {
                sh "sudo docker build --pull -t ${IMAGE_NAME}:${IMAGE_LATEST_TAG} ."
            }
        }

        stage('Trivy Docker Image Scan') {
            steps {
                echo "####################### ${YELLOW}Trivy Docker Image Scan${RESET_COLOR} #######################"
                sh "trivy image --no-progress --exit-code 1 --severity HIGH,CRITICAL ${IMAGE_NAME}:${IMAGE_LATEST_TAG} > trivyimage.txt"
            }
        }
        
        stage('Docker Push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: '729be586-4e3e-45ce-9ace-bf1d85f2a6c3', toolName: 'Docker', url: 'https://index.docker.io/v1/') {
                        sh "sudo docker push ${IMAGE_NAME}:${IMAGE_LATEST_TAG}"
                    }
                }
            }
        }

        // stage('Deploy to server') {
        //     steps {
        //         sshagent(['production-srv']) {
        //             sh "ssh -o StrictHostKeyChecking=no -l ${SERVER_CONNECTION}  'sudo docker stop ${APP_NAME} || true && sudo docker rm ${APP_NAME} || true'"
        //             sh "ssh -o StrictHostKeyChecking=no -l ${SERVER_CONNECTION} 'sudo docker run -p 4000:80 -d --name ${APP_NAME} --restart unless-stopped ${IMAGE_NAME}'"
        //         }
        //     }
        // }

        stage('Deploy to Kubernetes') {
            steps {
                echo "####################### ${PURPLE}Deploy to Kubernetes${RESET_COLOR} #######################"
                script {
                    dir('Kubernetes') {
                        withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'k8s', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
                            sh 'kubectl apply -f manifest.yml'
                            sh 'kubectl get svc'
                            sh 'kubectl get all'
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            emailext attachLog: true, 
            subject: "${currentBuild.result}",
            body: "Project: ${env.JOB_NAME}<br/>" +
            "Build Number: ${env.BUILD_NUMBER}<br/>" +
            "Docker Image Tag: ${IMAGE_LATEST_TAG}<br/>" +
            "URL: ${env.BUILD_URL}<br/>",
            to: 'fleeforezz@gmail.com',
            attachmentsPattern: 'trivyfs.txt, trivyimage.txt'
        }
    }
}