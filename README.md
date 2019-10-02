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
