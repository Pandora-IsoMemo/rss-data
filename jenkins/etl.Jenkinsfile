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
        REGISTRY = "ghcr.io/pandora-isomemo"
        CUR_PKG_FOLDER = '.' // defaults to root
        TMP_SUFFIX = """${sh(returnStdout: true, script: 'echo `cat /dev/urandom | tr -dc \'a-z\' | fold -w 6 | head -n 1`')}"""
        CREDENTIALS = credentials('rss-data-renviron')
        R_SCRIPT = 'inst/RScripts/exec_main.R'
    }
    stages {
        stage('rss-data-ETL') {
            steps {
                sh '''
                docker run --rm --network host \
                  --name $CUR_PROJ-ETL-$TMP_SUFFIX \
                 --env-file $CREDENTIALS \
                 $REGISTRY/$CUR_PROJ:main Rscript $R_SCRIPT
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

              slackSend(
                  channel: '#mpi-alerts',
                  message: "Job *${env.JOB_NAME} [${env.BUILD_NUMBER}]* finished with status: *${currentBuild.currentResult}* in ${currentBuild.durationString}. \nDetails: ${env.BUILD_URL}",
                  color: currentBuild.currentResult == 'SUCCESS' ? 'good' : (currentBuild.currentResult == 'FAILURE' ? 'danger' : 'warning')
              )
        }
    }
}
