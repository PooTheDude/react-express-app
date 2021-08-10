def call(def pipelineParams) {
    
    pipeline {
        
        agent {
            label 'slave'
        }

        environment {
            AWS_REGION = "${pipelineParams.AWS_REGION}"
            IMAGE_VERSION = "v_${BUILD_NUMBER}"
            DOCKER_REGISTRY = "${pipelineParams.DOCKER_REGISTRY}"
            DOCKER_TAG = "${pipelineParams.DOCKER_TAG}"
            ECS_CLUSTER = "${pipelineParams.ECS_CLUSTER}"
            ECS_SERVICE = "${pipelineParams.ECS_SERVICE}"
            TASK_FAMILY="${pipelineParams.TASK_FAMILY}"
            GIT_REPO = "${pipelineParams.GIT_REPO}"
            CREDENTIALS="${pipelineParams.CREDENTIALS}"
            BRANCH = "${pipelineParams.BRANCH}"
            ENV = "${pipelineParams.ENV}"
            POM_DIR = "${WORKSPACE}/${pipelineParams.POM_DIR}"
            NAME = "${pipelineParams.NAME}"
            PROJECT_NAME = "${pipelineParams.PROJECT_NAME}"
            PROJECT_KEY = "${pipelineParams.PROJECT_KEY}"
            SONAR_TOKEN = "sonar-report-token"
            RECIPIENT_LIST = "${pipelineParams.RECIPIENT_LIST}"
            }
    
        stages {

            stage('Email: JobStarted'){
                steps{
                    emailext attachLog: true,
                    compressLog: true,
                    body:'$DEFAULT_CONTENT',
                    recipientProviders: [[$class: 'DevelopersRecipientProvider']],
                    subject: "Jenkins Build Started: Job ${env.JOB_NAME}",
                    to:"${pipelineParams.RECIPIENT_LIST}"
                }
            }
            
            stage('Clean workspace') {
                steps {
                    cleanWs()
                    sh 'printenv'
                }
            }
            
            stage('Get Code') {
                steps {
                    checkout scm: [$class : 'GitSCM',
                    extensions: [[$class: 'RelativeTargetDirectory']],
                    userRemoteConfigs: [[url : "${GIT_REPO}",
                    credentialsId: "${CREDENTIALS}"]],
                    branches : [[name: "${BRANCH}"]]],
                    poll: false
                }
            }
          
            stage('Building image') {
              steps {
                    echo 'start building docker image'
                    sh '''
                        docker build -t ${DOCKER_REGISTRY}/${DOCKER_TAG}:${IMAGE_VERSION} -f app-module/Dockerfile .
                    '''
                }
            }
            
            stage('Push Artifact to ECR') {
                steps {
                   sh '''
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${DOCKER_REGISTRY}
                    docker push ${DOCKER_REGISTRY}/${DOCKER_TAG}:${IMAGE_VERSION}
                '''
                }
            }
            
            
            stage('Task provisioning') {
                steps {
                    sh '''
                    SERVICE_TASK_DEF=\$(aws ecs describe-services --cluster ${ECS_CLUSTER} --services ${ECS_SERVICE} --query services[].taskDefinition --output text | awk  -F"/" '{print $2}')
                    CURRENT_TASK_DEF=\$(aws ecs describe-task-definition --task-definition "${SERVICE_TASK_DEF}" --output json)
                    TEMP=\$(echo $CURRENT_TASK_DEF | jq --arg NDI "${DOCKER_REGISTRY}/${DOCKER_TAG}:${IMAGE_VERSION}" '.taskDefinition.containerDefinitions[0].image=$NDI')
                    NEW_TASK_DEF=\$(echo $TEMP | jq '.taskDefinition|{family: .family, volumes: .volumes, containerDefinitions: .containerDefinitions,networkMode: .networkMode,executionRoleArn: .executionRoleArn,cpu: .cpu,memory: .memory,taskRoleArn: .taskRoleArn}')
                    TASK_REVISION=$(aws ecs register-task-definition --family "${TASK_FAMILY}" --cli-input-json "$(echo $NEW_TASK_DEF)" )
                    '''
                }
            }
            
            stage('Deploy ecs service') {
               
               steps {
                   sh '''
                     TASK_REVISION=\$(aws ecs describe-task-definition --task-definition ${TASK_FAMILY} --query 'taskDefinition.revision' --output text)
                     aws ecs update-service --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --task-definition ${TASK_FAMILY}:${TASK_REVISION} --force-new-deployment
                   '''
                }
            }
            stage('Health Check') {
                steps {
                    sh '''
                    aws ecs wait services-stable --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} 
                    '''
                }
            }
            
            stage('Docker clean') {
                steps {
                    echo 'Remove Docker Image'
                    sh "docker rmi ${env.DOCKER_REGISTRY}/${env.DOCKER_TAG}:${env.IMAGE_VERSION}"
                }
            }
        }

        post {
            always {
                wrap([$class: 'BuildUser']) {
                    emailext attachLog: true,
                    compressLog: true,
                    body:'$DEFAULT_CONTENT',
                    recipientProviders: [[$class: 'DevelopersRecipientProvider']],
                    subject: "Jenkins Build ${currentBuild.currentResult}: Job ${env.JOB_NAME} trigerred by USER:${env.BUILD_USER} USER ID:${env.BUILD_USER_ID}",
                    to:"${pipelineParams.RECIPIENT_LIST}"
                }
            }
        }
        
    }
}
