# Docker image for hunspell

This is a lightweight docker image for [hunspell](http://hunspell.github.io).
Hunspell is spell checker.
See http://hunspell.github.io

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

