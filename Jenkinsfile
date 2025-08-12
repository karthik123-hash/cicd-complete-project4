pipeline {
    agent any

    environment {
        DOCKER_TAG = "20250812"
        IMAGE_NAME = "karthikputhran/fullstack"
        AWS_REGION = "us-east-1"
        CLUSTER_NAME = "project4-cluster"
    }

    tools {
        jdk 'java-17'
        maven 'maven'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'eks', url: 'https://github.com/karthik123-hash/cicd-complete-project4.git'
            }
        }

        stage('Compile') {
            steps {
                sh "mvn compile"
            }
        }

        stage('Build') {
            steps {
                sh "mvn package"
            }
        }

        stage('Build & Tag Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${DOCKER_TAG} ."
                }
            }
        }

        stage('Docker Image Scan') {
            steps {
                script {
                    sh "trivy image --format table -o trivy-image-report.html karthikputhran/fullstack:20250812"
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sh "docker push ${IMAGE_NAME}:${DOCKER_TAG}"
                }
            }
        }
        
        stage('Updating the Cluster') {
            steps {
                script {
                    sh "aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}"
                }
            }
        }
        
        stage('Deploy To Kubernetes') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'project4-cluster', contextName: '', credentialsId: 'kube', namespace: 'project-5', restrictKubeConfigAccess: false, serverUrl: 'https://36477810BFAE1E05454BD74AD28BD50C.gr7.us-east-1.eks.amazonaws.com') {
                    sh "kubectl get pods -n project-5"
                    sh "kubectl apply -f deployment.yml -n project-5"
                }
            }
        }

        stage('Verify the Deployment') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'project4-cluster', contextName: '', credentialsId: 'kube', namespace: 'project-5', restrictKubeConfigAccess: false, serverUrl: 'https://36477810BFAE1E05454BD74AD28BD50C.gr7.us-east-1.eks.amazonaws.com') {
                    sh "kubectl get pods -n project-5"
                    sh "kubectl get svc -n project-5"
                }
            }
        }
    }

    post {
        always {
            script {
                def jobName = env.JOB_NAME
                def buildNumber = env.BUILD_NUMBER
                def pipelineStatus = currentBuild.result ?: 'UNKNOWN'
                def bannerColor = pipelineStatus.toUpperCase() == 'SUCCESS' ? 'green' : 'red'

                def body = """
                    <html>
                    <body>
                    <div style="border: 4px solid ${bannerColor}; padding: 10px;">
                    <h2>${jobName} - Build ${buildNumber}</h2>
                    <div style="background-color: ${bannerColor}; padding: 10px;">
                    <h3 style="color: white;">Pipeline Status: ${pipelineStatus.toUpperCase()}</h3>
                    </div>
                    <p>Check the <a href="${BUILD_URL}">console output</a>.</p>
                    </div>
                    </body>
                    </html>
                """

                emailext (
                    subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus.toUpperCase()}",
                    body: body,
                    to: 'karthikaws109@gmail.com,puthran.369.karthik@gmail.com',
                    from: 'karthikaws109@gmail.com',
                    replyTo: 'karthikaws109@gmail.com',
                    mimeType: 'text/html',
                    attachmentsPattern: 'trivy-image-report.html'
                )
            }
        }
    }
}
