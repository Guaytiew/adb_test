# adb_test

pipeline {
    stages {
        stage('Setup') {
            steps {
                script {
                    try {
                        // Commands that may fail
                        sh 'python -m venv venv'
                        sh 'pip install -r requirements.txt'
                    } catch (Exception e) {
                        // Cleanup actions
                        sh 'rm -rf venv'
                        error "Build failed, cleaning up"
                    }
                }
            }
        }
    }
}
