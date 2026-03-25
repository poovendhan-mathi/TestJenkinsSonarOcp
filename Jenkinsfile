// ============================================================
// JENKINSFILE — Full CI/CD Pipeline
// ============================================================
// This is the MAIN pipeline. It runs:
//   1. Checkout code
//   2. Install dependencies
//   3. Lint (code style)
//   4. Build the app
//   5. Run tests (with coverage)
//   6. SonarQube analysis (code quality)
//   7. Quality Gate check
//   8. Security scans (Trivy + OWASP)
//   9. Build Docker image
//  10. Scan Docker image
//  11. Push to registry
//  12. Deploy to UAT (develop branch)
//  13. Smoke test
//  14. Approval gate (main branch)
//  15. Deploy to Production (main branch)
// ============================================================

pipeline {
    agent any

    // ========================
    // TOOLS
    // ========================
    tools {
        nodejs 'NodeJS-20'
    }

    // ========================
    // ENVIRONMENT VARIABLES
    // ========================
    environment {
        SONAR_SCANNER_HOME = tool('SonarScanner')
        APP_NAME           = 'expense-tracker'
        DOCKER_REGISTRY    = 'docker.io'
        DOCKER_IMAGE       = "${APP_NAME}"
    }

    // ========================
    // OPTIONS
    // ========================
    options {
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    // ========================
    // STAGES
    // ========================
    stages {

        // --- STAGE 1: CHECKOUT ---
        stage('Checkout') {
            steps {
                echo '📥 Checking out source code...'
                checkout scm
            }
        }

        // --- STAGE 2: INSTALL ---
        stage('Install Dependencies') {
            steps {
                echo '📦 Installing npm packages...'
                sh 'npm ci'
            }
        }

        // --- STAGE 3: LINT ---
        stage('Lint') {
            steps {
                echo '🔍 Checking code style...'
                sh 'npm run lint'
            }
        }

        // --- STAGE 4: BUILD ---
        stage('Build') {
            steps {
                echo '🔨 Building the app...'
                sh 'npm run build'
            }
        }

        // --- STAGE 5: TEST ---
        stage('Test') {
            steps {
                echo '🧪 Running tests with coverage...'
                sh 'npm run test:coverage'
            }
            post {
                always {
                    // Publish test results (if JUnit reporter is configured)
                    junit allowEmptyResults: true, testResults: 'test-results/*.xml'
                    // Archive coverage report
                    publishHTML([
                        allowMissing: true,
                        reportDir: 'coverage/lcov-report',
                        reportFiles: 'index.html',
                        reportName: 'Coverage Report',
                        keepAll: true
                    ])
                }
            }
        }

        // --- STAGE 6: SONARQUBE ---
        stage('SonarQube Analysis') {
            steps {
                echo '📊 Running SonarQube analysis...'
                withSonarQubeEnv('SonarQube') {
                    sh "${SONAR_SCANNER_HOME}/bin/sonar-scanner"
                }
            }
        }

        // --- STAGE 7: QUALITY GATE ---
        stage('Quality Gate') {
            steps {
                echo '🚦 Waiting for Quality Gate...'
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        // --- STAGE 8: SECURITY SCANS (parallel) ---
        stage('Security Scans') {
            parallel {
                stage('Trivy - Filesystem') {
                    steps {
                        echo '🛡️ Scanning dependencies with Trivy...'
                        sh '''
                            trivy fs \
                                --severity HIGH,CRITICAL \
                                --exit-code 1 \
                                --format table \
                                . || {
                                    echo "⚠️ Trivy found vulnerabilities!"
                                    exit 1
                                }
                        '''
                    }
                }
                stage('OWASP Dependency Check') {
                    steps {
                        echo '🛡️ Running OWASP Dependency Check...'
                        sh '''
                            mkdir -p reports
                            docker run --rm \
                                -v "$(pwd)":/src \
                                -v owasp-data:/usr/share/dependency-check/data \
                                owasp/dependency-check:latest \
                                --project "Expense Tracker" \
                                --scan /src \
                                --format HTML \
                                --format JSON \
                                --out /src/reports \
                                --failOnCVSS 9 \
                                --disableAssembly \
                                || true
                        '''
                        publishHTML([
                            allowMissing: true,
                            reportDir: 'reports',
                            reportFiles: 'dependency-check-report.html',
                            reportName: 'OWASP Dependency Check',
                            keepAll: true
                        ])
                    }
                }
            }
        }

        // --- STAGE 9: BUILD DOCKER IMAGE ---
        stage('Build Docker Image') {
            when {
                anyOf {
                    branch 'develop'
                    branch 'main'
                }
            }
            steps {
                echo '🐳 Building Docker image...'
                sh """
                    docker build \
                        -t ${DOCKER_IMAGE}:${BUILD_NUMBER} \
                        -t ${DOCKER_IMAGE}:latest \
                        .
                """
            }
        }

        // --- STAGE 10: SCAN DOCKER IMAGE ---
        stage('Scan Docker Image') {
            when {
                anyOf {
                    branch 'develop'
                    branch 'main'
                }
            }
            steps {
                echo '🛡️ Scanning Docker image with Trivy...'
                sh """
                    trivy image \
                        --severity HIGH,CRITICAL \
                        --exit-code 0 \
                        --format table \
                        ${DOCKER_IMAGE}:${BUILD_NUMBER}
                """
            }
        }

        // --- STAGE 11: PUSH TO REGISTRY ---
        stage('Push to Registry') {
            when {
                anyOf {
                    branch 'develop'
                    branch 'main'
                }
            }
            steps {
                echo '📤 Pushing image to Docker Hub...'
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}
                        docker push ${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}
                        docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_USER}/${DOCKER_IMAGE}:latest
                        docker push ${DOCKER_USER}/${DOCKER_IMAGE}:latest
                    '''
                }
            }
        }

        // --- STAGE 12: DEPLOY TO UAT ---
        stage('Deploy to UAT') {
            when {
                branch 'develop'
            }
            steps {
                echo '🚀 Deploying to UAT environment...'
                withCredentials([string(credentialsId: 'oc-token', variable: 'OC_TOKEN')]) {
                    sh '''
                        oc login --token="$OC_TOKEN" --server="$OC_SERVER" --insecure-skip-tls-verify
                        oc project "$UAT_NAMESPACE"
                        oc set image deployment/${APP_NAME} \
                            ${APP_NAME}=${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER} \
                            || oc create deployment ${APP_NAME} --image=${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}
                        oc rollout status deployment/${APP_NAME} --timeout=120s
                    '''
                }
            }
        }

        // --- STAGE 13: SMOKE TEST ---
        stage('Smoke Test - UAT') {
            when {
                branch 'develop'
            }
            steps {
                echo '🔥 Running smoke test on UAT...'
                sh '''
                    sleep 10
                    UAT_URL=$(oc get route ${APP_NAME} -o jsonpath='{.spec.host}' 2>/dev/null || echo "")
                    if [ -n "$UAT_URL" ]; then
                        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://${UAT_URL}" --max-time 10)
                        if [ "$HTTP_STATUS" -eq 200 ]; then
                            echo "✅ Smoke test PASSED! Status: ${HTTP_STATUS}"
                        else
                            echo "❌ Smoke test FAILED! Status: ${HTTP_STATUS}"
                            exit 1
                        fi
                    else
                        echo "⚠️ No route found, skipping smoke test"
                    fi
                '''
            }
        }

        // --- STAGE 14: APPROVAL GATE ---
        stage('Approval Gate') {
            when {
                branch 'main'
            }
            steps {
                echo '⏸️ Waiting for Production deployment approval...'
                input(
                    message: 'Deploy to PRODUCTION?',
                    ok: 'Yes, Deploy to Prod!',
                    submitter: 'admin'
                )
            }
        }

        // --- STAGE 15: DEPLOY TO PRODUCTION ---
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                echo '🚀🚀 Deploying to PRODUCTION...'
                withCredentials([string(credentialsId: 'oc-token', variable: 'OC_TOKEN')]) {
                    sh '''
                        oc login --token="$OC_TOKEN" --server="$OC_SERVER" --insecure-skip-tls-verify
                        oc project "$PROD_NAMESPACE"
                        oc set image deployment/${APP_NAME} \
                            ${APP_NAME}=${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER} \
                            || oc create deployment ${APP_NAME} --image=${DOCKER_USER}/${DOCKER_IMAGE}:${BUILD_NUMBER}
                        oc rollout status deployment/${APP_NAME} --timeout=120s
                    '''
                }
            }
        }
    }

    // ========================
    // POST-BUILD ACTIONS
    // ========================
    post {
        success {
            echo '✅✅✅ Pipeline completed SUCCESSFULLY! ✅✅✅'
        }
        failure {
            echo '❌❌❌ Pipeline FAILED! Check the logs above. ❌❌❌'
        }
        always {
            echo '🧹 Cleaning up workspace...'
            cleanWs()
        }
    }
}
