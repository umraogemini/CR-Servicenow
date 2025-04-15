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
        choice(name: 'GCP_PROJECT_ID', choices: ['hsbc-12609073-peakplat-dev', 'hsbc-12609073-peakmex-dev', 'hsbc-12609073-peakplatsit-dev', 'hsbc-12609073-peakmexsit-dev', 'hsbc-12609073-peakplatuat-dev', 'hsbc-12609073-peakmexuat-dev'], description: 'Google Cloud project ID')
        string(name: 'BUILD_SA', defaultValue: 'automation-deployment', description: 'GCP service account used for deploying Terraform modules')
        string(name: 'ENVIRONMENT', defaultValue: 'DEV', description: 'Deployment environment')
        choice(name: 'TF_MODULE', choices: ['CR-Servicenow'], description: 'Select the Terraform module to deploy')
        choice(name: 'GCP_REGION', choices: ['europe-west2', 'europe-west1'], description: 'GCP region for deployment')
        choice(name: 'TF_ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Terraform action to run')
        booleanParam(name: 'SKIP_CP_CHECK', defaultValue: false, description: 'Skip Change Request approval check from ServiceNow')
        string(name: 'RECIPIENTS', defaultValue: 'uma.rao@noexternalmail.hsbc.com', description: 'Recipients for pipeline notification emails')
    }

    stages {
        stage('run-on-gcp') {
            steps {
                script {
                    def pipelineId = "pipeline-${UUID.randomUUID().toString()}"
                    def WORKSPACE = env.WORKSPACE
                    def GCP_PROJECT_ID = params.GCP_PROJECT_ID
                    def ENVIRONMENT = params.ENVIRONMENT
                    def TF_MODULE = params.TF_MODULE
                    def TF_ACTION = params.TF_ACTION
                    def GCP_REGION = params.GCP_REGION
                    def SKIP_CP_CHECK = params.SKIP_CP_CHECK
                    def GCP_SA_KEY_ID = "${params.BUILD_SA}_${params.GCP_PROJECT_ID}"

                    echo "Using Pipeline ID: ${pipelineId}"
                    echo "Terraform Action: ${TF_ACTION} on ${TF_MODULE}"

                    withCredentials([file(credentialsId: GCP_SA_KEY_ID, variable: 'GCP_SA_KEY_FILE')]) {
                        withCredentials([file(credentialsId: "NETRC_CONFIG", variable: 'NETRC_CONFIG_FILE')]) {
                            script {
                                sh """
                                set -e

                                mkdir -p ${WORKSPACE}/${pipelineId}/gcp_projects/${GCP_PROJECT_ID}/${TF_MODULE}
                                mkdir -p ${WORKSPACE}/${pipelineId}
                                cp -r ./gcp_projects ./modules ${WORKSPACE}/${pipelineId}
                                cp "${GCP_SA_KEY_FILE}" ${WORKSPACE}/${pipelineId}/secret-sa.json
                                chmod 700 ${WORKSPACE}/${pipelineId}/secret-sa.json

                                cp "${NETRC_CONFIG_FILE}" ${WORKSPACE}/${pipelineId}/gcp_projects/${GCP_PROJECT_ID}/${TF_MODULE}/.netrc
                                chmod 700 ${WORKSPACE}/${pipelineId}/gcp_projects/${GCP_PROJECT_ID}/${TF_MODULE}/.netrc

                                mkdir -p "${terraform_provider_home}"
                                cp "${NETRC_CONFIG_FILE}" "${terraform_provider_home}/.netrc"
                                chmod 700 "${terraform_provider_home}/.netrc"

                                export GOOGLE_APPLICATION_CREDENTIALS="${WORKSPACE}/${pipelineId}/secret-sa.json"
                                export HOME="${terraform_provider_home}"
                                export HTTP_PROXY="http://googleapis-dev.gcp.cloud.uk.hsbc:3128"
                                export HTTPS_PROXY="http://googleapis-dev.gcp.cloud.uk.hsbc:3128"
                                export NO_PROXY=".hsbc"

                                cd ${WORKSPACE}/${pipelineId}/gcp_projects/${GCP_PROJECT_ID}/${TF_MODULE}

                                terraform init -upgrade=false -no-color
                                terraform validate -no-color
                                terraform workspace select "${ENVIRONMENT}" 2>/dev/null || terraform workspace new "${ENVIRONMENT}"
                                if [[ "${TF_ACTION}" == "apply" ]]; then
                                    terraform apply -auto-approve -no-color -var-file="${ENVIRONMENT}.tfvars" -var="project_id=${GCP_PROJECT_ID}"
                                elif [[ "${TF_ACTION}" == "plan" ]]; then
                                    terraform plan -out=tfplan -no-color -var-file="${ENVIRONMENT}.tfvars" -var="project_id=${GCP_PROJECT_ID}"
                                else
                                    terraform destroy -auto-approve -no-color -var-file="${ENVIRONMENT}.tfvars" -var="project_id=${GCP_PROJECT_ID}"
                                fi
                            """
                        }
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

Check console output at ${env.BUILD_URL} to view the results.""",
                    subject: """${currentBuild.result == 'SUCCESS' ? 'SUCCESS:' : 'FAILURE:'} Pipeline '${env.JOB_NAME} [${env.BUILD_NUMBER}]'""",
                    to: "${params.RECIPIENTS}"
                )
            }
        }
        failure {
            script {
                emailext(
                    body: """Pipeline '${env.JOB_NAME} [${env.BUILD_NUMBER}]' : FAILURE

Check console output at ${env.BUILD_URL} to view the results.""",
                    subject: """FAILURE: Pipeline '${env.JOB_NAME} [${env.BUILD_NUMBER}]'""",
                    to: "${params.RECIPIENTS}"
                )
            }
        }
    }
}
