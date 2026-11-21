
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    environment {
        AWS_ACCOUNT_ID = '887074880802'
        AWS_REGION     = 'eu-north-1'
        ECR_REPOSITORY = 'front-end-web'
        ECR_REGISTRY   = '887074880802.dkr.ecr.eu-north-1.amazonaws.com'

        IMAGE_NAME     = 'frontend-container'
        CONTAINER_NAME = 'frontend-container'
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo 'Downloading source code from GitHub...'
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building frontend Docker image...'

                sh '''
                    docker build --pull \
                    -t ${ECR_REGISTRY}/${ECR_REPOSITORY}:${BUILD_NUMBER} \
                    -t ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest .
                '''
            }
        }

        stage('Login to AWS ECR') {
            steps {
                echo 'Authenticating with Amazon ECR...'

                sh '''
                    aws ecr get-login-password \
                    --region ${AWS_REGION} | \
                    docker login \
                    --username AWS \
                    --password-stdin ${ECR_REGISTRY}
                '''
            }
        }

        stage('Push Image to ECR') {
            steps {
                echo 'Pushing Docker image to ECR...'

                sh '''
                    docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${BUILD_NUMBER}

                    docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest
                '''
            }
        }

        stage('Deploy on EC2') {
            steps {
                echo 'Deploying frontend container...'

                sh '''
                    # Pull the newly built image
                    docker pull ${ECR_REGISTRY}/${ECR_REPOSITORY}:${BUILD_NUMBER}

                    # Remove previous containers if present
                    for container in frontend-container frontend-website; do
                        docker rm -f "$container" 2>/dev/null || true
                    done

                    # Start the new frontend container
                    docker run -d \
                        --name ${CONTAINER_NAME} \
                        --restart unless-stopped \
                        -p 80:80 \
                        ${ECR_REGISTRY}/${ECR_REPOSITORY}:${BUILD_NUMBER}

                    # Verify deployment
                    sleep 5

                    curl -f http://localhost/ || {
                        echo "Frontend deployment health check failed!"
                        exit 1
                    }

                    echo "Frontend deployed successfully!"
                '''
            }
        }
    }

    post {
        success {
            echo 'CI/CD Pipeline completed successfully!'
            echo 'Frontend website is running on EC2 port 80.'
        }

        failure {
            echo 'CI/CD Pipeline failed. Check the stage logs.'
        }

        always {
            sh 'docker logout ${ECR_REGISTRY} || true'
        }
    }
}
