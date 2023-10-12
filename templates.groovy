NAMESPACE_TEMPLATE = '''
kind: Namespace
apiVersion: v1
metadata:
  name: ${name}
  labels:
    name: ${name}
'''

CLUSTER_TEMPLATE = '''
apiVersion: v1
kind: Secret
metadata:
  name: ${name}
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
type: Opaque
stringData:
  name: ${name}
  server: ${endpoint}
  config: |
    {
      "bearerToken": "${token}",
      "tlsClientConfig": {
        "insecure": false,
        "caData": "${caCert}"
      }
    }
'''

REPOSITORY_TEMPLATE = '''
apiVersion: v1
kind: Secret
metadata:
  name: ${name}
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
data:
stringData:
  password: ${password}
  project: default
  type: git
  url: ${url}
  username: ${username}
'''

APP_TEMPLATE = '''
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${name}
  namespace: ${namespace}
spec:
  destination:
    server: ${dst_server}
    namespace: ${dst_namespace}
  project: ${project}
  source:
    path: ${src_path}
    repoURL: ${src_repo}
    targetRevision: ${src_branch}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
'''

ARGOCD_SET_ADMIN_PASSWORD = '''
kubectl ${ctx} -n argocd patch secret argocd-secret \\
  -p '{"stringData": {
    "admin.password": "${password}",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'
'''

def renderTemplate(tmpl, bindings) {
  bindings.inject(tmpl) { t, k, v -> t.replace("\${" + k + "}", v) }
}

return this
