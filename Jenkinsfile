// Definición de variables globales que serán usadas en el Jenkinsfile.
// Vault Jenkins
def SA_ID = 'dbeans-jenkins'
def SEALED_SECRETS_ID = 'dbeans-sealed-secrets-key'

// Entorno
def PROJECT_ID = 'dbeans'
def BUCKET_NAME = 'dbeans-cp-tf-state'
def GKE_CLUSTER_NAME = 'dbeans-dev'
def GCP_ZONE = 'europe-southwest1-a'

// Inicio del pipeline.
node('docker-terraform') {

    // Etapa para obtener el código del repositorio de Git.
    stage('Checkout Code') {
        git credentialsId: 'dbeans-gh-2',
            branch: 'main',
            url: 'https://github.com/cripsisxyz/chia-dbeans-infra.git'
    }

    // Uso de credenciales para autenticación.
    withCredentials([file(credentialsId: SA_ID, variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
        
        // Etapa para activar la cuenta de servicio en GCP.
        stage('Activar Service Account') {
            sh "gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS --project $PROJECT_ID"
        }

        // Etapa para verificar si un bucket específico ya existe en GCP.
        stage('Comprobar si el Bucket Existe') {
            script {
                def bucketExists = true
                try {
                    sh "gsutil ls gs://$BUCKET_NAME"
                } catch (Exception e) {
                    bucketExists = false
                }

                // Si el bucket no existe, se crea.
                if (!bucketExists) {
                    stage('Crear Bucket') {
                        sh "gsutil mb gs://$BUCKET_NAME"
                    }
                } else {
                    echo("El bucket $BUCKET_NAME ya existe. Continuando.")
                }
            }
        }

        // Etapa para crear o actualizar un clúster de GKE usando Terraform.
        stage('Terraform GKE Cluster') {
            retry(4) {
                withCredentials([file(credentialsId: SA_ID, variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh "terraform init -reconfigure -no-color"
                    sh "terraform apply -var gke_cluster_name=\"${GKE_CLUSTER_NAME}\" -auto-approve -no-color"
                }
            }
        }
    }

    // Etapa para configurar kubectl con las credenciales del clúster creado.
    stage('Configurar kubectl') {
        sh "gcloud container clusters get-credentials ${GKE_CLUSTER_NAME} --project ${PROJECT_ID} --zone ${GCP_ZONE}" 
    }

    // Etapa para configurar RBAC para ArgoCD en el clúster.
    stage('Configurar RBAC para ArgoCD') {
        sh "kubectl apply -f jenkins-k8s/argocd-serviceAccount.yaml"
    }

    // Etapa para instalar Sealed-secrets en el clúster.
    stage('Instalar k8s Sealed-secrets') {
        withCredentials([file(credentialsId: SEALED_SECRETS_ID, variable: 'K8S_SEALED_SECRETS_KEY')]) {
            sh "kubectl apply -f ${K8S_SEALED_SECRETS_KEY}"
        }
        sh "kubectl apply -f jenkins-k8s/sealed-secrets-installer.yaml"
    }

    // Etapa para instalar ArgoCD en el clúster.
    stage('Instalar ArgoCD') {
        def templates = load "templates.groovy"
        
        // Crear un namespace para ArgoCD.
        writeFile file: 'jenkins-k8s/argocd-ns.yaml',
        text: templates.renderTemplate(templates.NAMESPACE_TEMPLATE, ['name': 'argocd'])
        sh "kubectl apply -f jenkins-k8s/argocd-ns.yaml"
        sh "kubectl apply -n argocd -f jenkins-k8s/argocd-installer.yaml"

        // Configurar repositorios en ArgoCD.
        // Aquí se configuran dos repositorios diferentes para ArgoCD.
        // Ambos requieren autenticación, por lo que se usan credenciales y se crean secrets en Kubernetes.
        
        // Primer repositorio.
        def repoURL1 = 'https://github.com/cripsisxyz/chia-dbeans-infra.git'
        withCredentials([usernamePassword(credentialsId: 'dbeans-gh-2', variable: 'pass')]) {
            writeFile file: 'jenkins-k8s/repo-secret1.yaml',
            text: templates.renderTemplate(templates.REPOSITORY_TEMPLATE, ['name': 'repo-crossplane-base', 'password': pass, 'username': 'cripsisxyz', 'url': repoURL1])
        }

        // Aplicar los secrets y configuraciones de ArgoCD en el clúster.
        sh "kubectl apply -f jenkins-k8s/repo-secret1.yaml"
        sh "kubectl apply -f jenkins-k8s/argocd-gcp-credentials-syn-k8s.yaml"
        sh "kubectl apply -f jenkins-k8s/argocd-app-common-resources.yaml"
        sh "kubectl apply -f jenkins-k8s/argocd-applicationset.yaml"
        sh "kubectl apply -f jenkins-k8s/argocd-cloud-products-infra-admin.yaml"
        sh "kubectl apply -f jenkins-k8s/argocd-app-synthetix-saas-dev.yaml"
        // sh "kubectl apply -f jenkins-k8s/argocd-cluster-synthetix-saas-k8s.yaml"

        // Establecer la contraseña del administrador para ArgoCD.
        def argocdAdminPassword = '$2a$10$oX0FNR3knYLLVo9/dwIOiuNRxEQvEhBnAdO89TxENvo/.0tL1.Mq6'
        def kubectlCommand = templates.renderTemplate(templates.ARGOCD_SET_ADMIN_PASSWORD, ['password': argocdAdminPassword])
        sh "${kubectlCommand}"
    }
}
