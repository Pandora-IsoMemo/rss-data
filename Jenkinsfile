pipeline {
    agent any
    options { disableConcurrentBuilds() }
    environment {
        CUR_PROJ = 'rss-data' // github repo name
        CUR_PKG_FOLDER = '.' // defaults to root
        TMP_SUFFIX = """${sh(returnStdout: true, script: 'echo `cat /dev/urandom | tr -dc \'a-z\' | fold -w 6 | head -n 1`')}"""
        CREDENTIALS = credentials('rss-data-renviron')
    }
    stages {
        stage('Testing') {
            steps {
                sh '''
                docker build -t tmp-$CUR_PROJ-$TMP_SUFFIX .
                docker run --rm --network host \
                 --env-file $CREDENTIALS \
                 tmp-$CUR_PROJ-$TMP_SUFFIX check
                docker rmi tmp-$CUR_PROJ-$TMP_SUFFIX
                '''
            }
        }

    }
}
