pipeline {
    agent any
    triggers {
      cron('H 7 * * *')
    }
    options {
      disableConcurrentBuilds()
      buildDiscarder(logRotator(daysToKeepStr: '30'))
      timeout(time: 10, unit: 'MINUTES')
    }
    environment {
        CUR_PROJ = 'rss-data' // github repo name
        CUR_PKG_FOLDER = '.' // defaults to root
        TMP_SUFFIX = """${sh(returnStdout: true, script: 'echo `cat /dev/urandom | tr -dc \'a-z\' | fold -w 6 | head -n 1`')}"""
        CREDENTIALS = credentials('rss-data-renviron')
    }
    stages {
        stage('rss-data-ETL') {
            steps {
                sh '''
                docker run --rm --network host \
                 --env-file $CREDENTIALS \
                 $CUR_PROJ-ETL-$TMP_SUFFIX
                '''
            }
            post {
                always {
                    cleanWs()
                }
            }
        }
    }
    post {
     always {
         sh '''
         docker stop $CUR_PROJ-$JOB_NAME-$TMP_SUFFIX || :
         '''
      }
    }
}
