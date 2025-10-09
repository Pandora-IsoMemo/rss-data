pipeline {
    agent any
    triggers {
        cron('H 7 * * *')
    }
    options { disableConcurrentBuilds() }
    environment {
        CUR_PROJ = 'rss-data' // github repo name
        CUR_PKG_FOLDER = '.' // defaults to root
        TMP_SUFFIX = """${sh(returnStdout: true, script: 'echo `cat /dev/urandom | tr -dc \'a-z\' | fold -w 6 | head -n 1`')}"""
        CREDENTIALS = credentials('rss-data-renviron')
    }
    stages {
        stage('ETL') {
            when  { branch 'main' }
            steps {
                sh '''
                docker run --rm --network host \
                 --env-file $CREDENTIALS \
                 $CUR_PROJ-ETL-$TMP_SUFFIX
                docker rmi $CUR_PROJ-ETL-$TMP_SUFFIX
                '''
            }
        }
    }
}
