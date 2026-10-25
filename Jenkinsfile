
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm ci'
            }
        }

        stage('Test') {
            steps {
                sh 'npm test -- --runInBand'
            }
        }

        stage('Build') {
            steps {
                echo 'Build stage completed'
            }
        }
    }

    post {
        success {
            echo 'CI Pipeline Successful!'
        }
        failure {
            echo 'CI Pipeline Failed!'
        }
    }
}
