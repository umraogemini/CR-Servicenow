pipeline {
    agent { label "gcp-bffpeak-jenkins-slave" }

    environment {
        SERVICENOW_INSTANCE_URL = "https://hsbcitidu.service-now.com/servicenow"
        REQUESTED_BY = "uma.rao@noexternalmail.hsbc.com"
        ASSIGNMENT_GROUP = "ET-FINEX-BFF-PEAK-IT"
        SHORT_DESCRIPTION = "Automated CR via Terraform"
        DESCRIPTION = "Created for deployment automation"
        RISK = "low"
        IMPACT = "low"
        terraform_provider_home = "/hsbc/terraform_provider"
    }

    options {
        buildDiscarder(logRotator(daysToKeepStr: '7', numToKeepStr: '10'))
    }

    parameters {
        choice(name: 'GCP_PROJECT_ID', choices: ['hsbc-12609073-peakplat-dev', 'hsbc-12609073-peakmex-dev'], description: 'Google Cloud project ID')
        string(name: 'BUILD_SA', defaultValue: 'automation-deployment', description: 'GCP service account used')
        string(name: 'ENVIRONMENT', defaultValue: 'DEV', description: 'Deployment environment')
        choice(name: 'TF_MODULE', choices: ['CR-Servicenow'], description: 'Terraform module to deploy')
        choice(name: 'GCP_REGION', choices: ['europe-west2'], description: 'GCP region')
        choice(name: 'TF_ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Terraform action')
        booleanParam(name: 'SKIP_CP_CHECK', defaultValue: false, description: 'Skip Change Request check')
        string(name: 'RECIPIENTS', defaultValue: 'uma.rao@noexternalmail.hsbc.com', description: 'Notification recipients')
    }

    stages {
        stage('Terraform Deployment') {
            steps {
                script {
                    def pipelineId = "pipeline-${UUID.randomUUID().toString()}"
                    def WORKSPACE = env.WORKSPACE

                    withCredentials([file(credentialsId: "${params.BUILD_SA}_${params.GCP_PROJECT_ID}", variable: 'GCP_SA_KEY_FILE')]) {
                        sh '''
                            set -e
                            mkdir -p ${WORKSPACE}/${pipelineId}
                            cp -r ./CR-Servicenow/* ${WORKSPACE}/${pipelineId}/

                            cd ${WORKSPACE}/${pipelineId}

                            terraform init -no-color
                            terraform validate -no-color
                            terraform workspace select "${params.ENVIRONMENT}" 2>/dev/null || terraform workspace new "${params.ENVIRONMENT}"

                            if [[ "${params.TF_ACTION}" == "apply" ]]; then
                                terraform apply -auto-approve -no-color
                            elif [[ "${params.TF_ACTION}" == "plan" ]]; then
                                terraform plan -out=tfplan -no-color
                            else
                                terraform destroy -auto-approve -no-color
                            fi
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
            script {
                emailext(
                    body: """Pipeline '${env.JOB_NAME} [${env.BUILD_NUMBER}]' : ${currentBuild.result}

Check console output at ${env.BUILD_URL}""",
                    subject: """${currentBuild.result == 'SUCCESS' ? 'SUCCESS:' : 'FAILURE:'} Pipeline '${env.JOB_NAME} [${env.BUILD_NUMBER}]'""",
                    to: "${params.RECIPIENTS}"
                )
            }
        }
    }
}
