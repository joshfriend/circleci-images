#!/bin/bash

function generate_node_variant() {
  DESIRED_NODE_TAG=$1

  cat <<'EOF'
###
### DO NOT MODIFY THIS FILE.  THIS FILE HAS BEEN AUTOGENERATED
###

FROM {{BASE_IMAGE}}

# node installations command expect to run as root
USER root
EOF

  NODE_MANIFEST_INFO=$(curl --silent --location --fail --retry 3 https://raw.githubusercontent.com/docker-library/official-images/master/library/node | grep -A3 "$DESIRED_NODE_TAG")
  NODE_GIT_COMMIT=$(printf "%s\n" "${NODE_MANIFEST_INFO}" | grep GitCommit | awk '{print $2;}')
  NODE_DIRECTORY=$(printf "%s\n" "${NODE_MANIFEST_INFO}" | grep Directory | awk '{print $2;}')

  NODE_DOCKERFILE_URL="https://raw.githubusercontent.com/nodejs/docker-node/${NODE_GIT_COMMIT}/${NODE_DIRECTORY}/Dockerfile"
  echo "## Using node installation from $NODE_DOCKERFILE_URL"
  curl --silent --location --fail --retry 3 "$NODE_DOCKERFILE_URL" | grep -v -e '^FROM buildpack-deps:jessie' -e '^CMD'

  echo ''
  echo '# Basic smoke test'
  echo 'RUN node --version'

  echo ''
  echo 'USER circleci'
}

function generate_node_browser_variant() {
  printf "#\n# DO NOT MODIFY THIS FILE.  THIS FILE HAS BEEN AUTOGENERATED\n#\n"
  echo 'FROM {{BASE_IMAGE}}-node'
  cat ../shared/images/Dockerfile-browsers.template | grep -v '^FROM'
}

mkdir -p resources
generate_node_variant "carbon$" > resources/Dockerfile-node.template
generate_node_browser_variant > resources/Dockerfile-node-browsers.template

