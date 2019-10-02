#!/usr/bin/env bash

#https://github.com/wodby/elasticsearch/blob/master/bin/docker-entrypoint.sh

set -e

if [[ -n "${DEBUG}" ]]; then
    set -x
fi

install_plugins() {
    if [[ -n "${ES_PLUGINS_INSTALL}" ]]; then
       IFS=',' read -r -a plugins <<< "${ES_PLUGINS_INSTALL}"
       for plugin in "${plugins[@]}"; do
          if ! elasticsearch-plugin list | grep -qs "${plugin}"; then
             yes | elasticsearch-plugin install --batch "${plugin}"
          fi
       done
    fi
}

# The virtual file /proc/self/cgroup should list the current cgroup
# membership. For each hierarchy, you can follow the cgroup path from
# this file to the cgroup filesystem (usually /sys/fs/cgroup/) and
# introspect the statistics for the cgroup for the given
# hierarchy. Alas, Docker breaks this by mounting the container
# statistics at the root while leaving the cgroup paths as the actual
# paths. Therefore, Elasticsearch provides a mechanism to override
# reading the cgroup path from /proc/self/cgroup and instead uses the
# cgroup path defined the JVM system property
# es.cgroups.hierarchy.override. Therefore, we set this value here so
# that cgroup statistics are available for the container this process
# will run in.
export ES_JAVA_OPTS="-Des.cgroups.hierarchy.override=/ $ES_JAVA_OPTS"

# Generate random node name if not set.
if [[ -z "${ES_NODE_NAME}" ]]; then
	export ES_NODE_NAME=$(uuidgen)
fi

# Fix volume permissions.
chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/data

install_plugins

exec "/usr/local/bin/docker-entrypoint.sh"