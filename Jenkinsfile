pipeline {
    agent {
        label 'docker-agent'
    }

    options {
        disableConcurrentBuilds()
    }

    tools {
        nodejs 'NodeJS-22'
    }

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

        stage('Run Tests') {
            steps {
                sh 'npm test'
            }
        }

        stage('Determine Release Version') {
            steps {
                script {
                    def previousBuild = currentBuild.previousSuccessfulBuild

                    if (previousBuild == null) {
                        error('No previous successful build found.')
                    }

                    def previousDescription =
                        previousBuild.description ?: ''

                    def versionMatch =
                        (previousDescription =~ /RELEASE_VERSION=(\d+)\.(\d+)/)

                    if (!versionMatch.find()) {
                        error('Previous successful build has no RELEASE_VERSION description.')
                    }

                    def major = versionMatch.group(1)
                    def minor = versionMatch.group(2).toInteger() + 1

                    env.RELEASE_VERSION = "${major}.${minor}"

                    echo "Next Docker release: ${env.RELEASE_VERSION}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t nexaprime-ci-cd:${RELEASE_VERSION} .'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKERHUB_USER',
                    passwordVariable: 'DOCKERHUB_TOKEN'
                )]) {
                    sh '''
                        set +x
                        set -eu

                        trap 'docker logout >/dev/null 2>&1 || true' EXIT

                        printf '%s' "$DOCKERHUB_TOKEN" | docker login \
                            --username "$DOCKERHUB_USER" \
                            --password-stdin

                        docker tag "nexaprime-ci-cd:${RELEASE_VERSION}" \
                            "$DOCKERHUB_USER/nexaprime:${RELEASE_VERSION}"

                        docker push "$DOCKERHUB_USER/nexaprime:${RELEASE_VERSION}"
                    '''
                }

                script {
                    currentBuild.description =
                        "RELEASE_VERSION=${env.RELEASE_VERSION}"

                    echo "Successfully published release ${env.RELEASE_VERSION}"
                }
            }
        }
    }

    post {
        success {
            echo "CI/CD Pipeline completed successfully! Release: ${env.RELEASE_VERSION}"
        }

        failure {
            echo 'Pipeline failed. No release version was recorded.'
        }
    }
}
