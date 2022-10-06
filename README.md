# Docker image for hunspell

This is a lightweight [hunspell](http://hunspell.github.io) docker image volume for [Elasticsearch](https://www.elastic.co/)

You can also use this image as init Container for your Elasticsearch in Kubernetes and [share volume](https://kubernetes.io/docs/tasks/access-application-cluster/communicate-containers-same-pod-shared-volume/) path `/usr/share/elasticsearch/config/hunspell/` between containers.

## How to test it?

```
docker-compose up -d
```

Open Kibana in web browser http://localhost:5601 and go to Dev Tools and paste:

```
PUT products  
{
  "settings": {
    "index": {
      "number_of_shards": "1",
      "number_of_replicas": "0",
      "analysis": {
        "analyzer": {
          "czech": {
            "type": "custom",
            "tokenizer": "standard",
            "filter": [
              "czech_hunspell",
              "asciifolding",
              "lowercase"
            ]
          }
        },
        "filter": {
          "czech_hunspell": {
            "type": "hunspell",
            "locale": "cs_CZ"
          }
        }
      }
    }
  }
}

GET products/_analyze  
{
  "analyzer": "czech",
  "text": "Jahody cerstvé - ve vanicce"
}
```

## HELM config

```bash
helm repo add opensearch https://opensearch-project.github.io/helm-charts/
helm repo update
helm install --namespace=opensearch my-opensearch opensearch/opensearch --values=values-opensearch-2.6.2.yaml --version=2.6.2
```

### values-opensearch-2.6.2.yaml
```yaml
antiAffinity: soft
antiAffinityTopologyKey: kubernetes.io/hostname
clusterName: opensearch-cluster
config:
  opensearch.yml: >
    cluster.name: opensearch-cluster


    # Bind to all interfaces because we don't know what IP address Docker will
    assign to us.

    network.host: 0.0.0.0


    # Setting network.host to a non-loopback address enables the annoying
    bootstrap checks. "Single-node" mode disables them again.

    # Implicitly done if ".singleNode" is set to "true".

    # discovery.type: single-node
enableServiceLinks: true
envFrom: []
extraContainers: []
extraEnvs:
  - name: 'DISABLE_INSTALL_DEMO_CONFIG'
    value: 'true'
  - name: 'DISABLE_SECURITY_PLUGIN'
    value: 'true'
extraInitContainers:
  - name: 'hunspell'
    image: 'insekticid/elasticsearch-hunspell'
    command: ['cp', '-R', '/usr/share/elasticsearch/config/hunspell/', '/data/']
    volumeMounts:
      - mountPath: '/data/hunspell/'
        name: 'shared-data'
  - name: 'ini-sysctl'
    securityContext:
        runAsUser: 0
        privileged: true
    image: busybox:latest
    command: ['sysctl', '-w','vm.max_map_count=262144']
extraObjects: []
extraVolumeMounts:
  - mountPath: '/usr/share/opensearch/config/hunspell/'
    name: 'shared-data'
extraVolumes:
  - name: shared-data
    emptyDir: {}
fsGroup: ''
fullnameOverride: ''
global:
  dockerRegistry: ''
hostAliases: []
httpPort: 9200
image:
  pullPolicy: IfNotPresent
  repository: opensearchproject/opensearch
  tag: ''
imagePullSecrets: []
ingress:
  annotations: {}
  enabled: false
  hosts:
    - chart-example.local
  path: /
  tls: []
initResources: {}
keystore: []
labels: {}
lifecycle: {}
livenessProbe: {}
majorVersion: ''
masterService: opensearch-cluster-master
masterTerminationFix: false
maxUnavailable: 1
nameOverride: ''
networkHost: 0.0.0.0
networkPolicy:
  create: false
  http:
    enabled: false
nodeAffinity: {}
nodeGroup: master
nodeSelector: {}
opensearchHome: /usr/share/opensearch
opensearchJavaOpts: '-Xmx512M -Xms512M'
persistence:
  accessModes:
    - ReadWriteOnce
  annotations: {}
  enableInitChown: true
  enabled: false
  labels:
    enabled: false
  size: 8Gi
plugins:
  enabled: true
  installList:
    - analysis-icu
    - analysis-phonetic
podAnnotations: {}
podManagementPolicy: Parallel
podSecurityContext:
  fsGroup: 1000
  runAsUser: 1000
podSecurityPolicy:
  create: false
  name: ''
  spec:
    fsGroup:
      rule: RunAsAny
    privileged: true
    runAsUser:
      rule: RunAsAny
    seLinux:
      rule: RunAsAny
    supplementalGroups:
      rule: RunAsAny
    volumes:
      - secret
      - configMap
      - persistentVolumeClaim
      - emptyDir
priorityClassName: ''
protocol: https
rbac:
  create: false
  serviceAccountAnnotations: {}
  serviceAccountName: ''
readinessProbe:
  failureThreshold: 3
  periodSeconds: 5
  tcpSocket:
    port: 9200
  timeoutSeconds: 3
replicas: 3
resources:
  requests:
    cpu: 1000m
    memory: 100Mi
roles:
  - master
  - ingest
  - data
  - remote_cluster_client
schedulerName: ''
secretMounts: []
securityConfig:
  actionGroupsSecret: null
  config:
    data: {}
    dataComplete: true
    securityConfigSecret: ''
  configSecret: null
  enabled: true
  internalUsersSecret: null
  path: /usr/share/opensearch/plugins/opensearch-security/securityconfig
  rolesMappingSecret: null
  rolesSecret: null
  tenantsSecret: null
securityContext:
  capabilities:
    drop:
      - ALL
  runAsNonRoot: true
  runAsUser: 1000
service:
  annotations: {}
  externalTrafficPolicy: ''
  headless:
    annotations: {}
  httpPortName: http
  labels: {}
  labelsHeadless: {}
  loadBalancerIP: ''
  loadBalancerSourceRanges: []
  nodePort: ''
  transportPortName: transport
  type: ClusterIP
sidecarResources: {}
singleNode: false
startupProbe:
  failureThreshold: 30
  initialDelaySeconds: 5
  periodSeconds: 10
  tcpSocket:
    port: 9200
  timeoutSeconds: 3
sysctl:
  enabled: false
sysctlVmMaxMapCount: 262144
terminationGracePeriod: 120
tolerations: []
topologySpreadConstraints: []
transportPort: 9300
updateStrategy: RollingUpdate
```

## Kubernetes example

![Kubernetes example](/kubernetes/example.png)

[Kubernetes example yaml](/kubernetes/elasticsearch.yaml)


## You can also use this image standalone for hunspell checking

The working directory is at `/workdir`. Mount your volume into that directory.

```bash
$ docker run --rm -v $(pwd):/workdir insekticid/elasticsearch-hunspell:latest -H public/**/*.html
```

## Other languages

List all languages available:

```bash
docker run --rm insekticid/elasticsearch-hunspell -D
```

Example:

```bash
$ docker run --rm -v $(pwd):/workdir insekticid/elasticsearch-hunspell -u3 -i utf-8 -d cs_CZ -p words -H public/**/*.html
```

## Continuous Integration (CI)

Run in report mode

```bash
$ docker run --rm -v $(pwd):/workdir insekticid/elasticsearch-hunspell -u3 -H public/**/*.html
```

Common credits belongs to [@ludekvesely](https://github.com/ludekvesely) and [@tmaier](https://github.com/tmaier)
