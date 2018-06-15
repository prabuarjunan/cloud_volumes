#!/bin/Bash

function start() {
  docker build -t clouddocs-env ./docker/clouddocs.env/
  docker build --no-cache -t build_"$JEKYLL_PORT"_1 .
  pwd=$(pwd);
  docker run -it -d -p $JEKYLL_PORT:$JEKYLL_PORT -v /$pwd:/src --name=build_"$JEKYLL_PORT"_1 build_"$JEKYLL_PORT"_1
  sleep 10s;
  getStatus;
}

function stop() {
  docker stop build_"$JEKYLL_PORT"_1
  docker rm -v build_"$JEKYLL_PORT"_1
  sleep 5s;
}

function getStatus() {
  status=$(docker ps --filter status=running | grep $JEKYLL_PORT);
  if [[ -z "$JEKYLL_BASEURL" ]]; then
    echo "Container not running";
  else
    echo "Running at http://localhost:"$JEKYLL_PORT$JEKYLL_BASEURL"/";
  fi
}

function restart() {
  stop;
  start;
}

function setBaseUrl() {
  echo "Setting site baseurl to: $JEKYLL_BASEURL";
  sed -i 's/\/jekyll/'$JEKYLL_BASEURL'/g' ./_config.yml
}

function setNSSProduct() {
  if [[ -z "$NSS_PRODUCT" ]]; then
    echo "[WARN] The NSS Product Name is empty";
  else
    echo "Setting NSS Product Name to: $NSS_PRODUCT";
    echo "nss_product: $NSS_PRODUCT" >> ./_config.yml
  fi
}

function getDockerUrl() {
  DOCKER_URL_WINDOWS="docker\.for\.win\.localhost\:9200\/";
  DOCKER_URL_MAC="docker\.for\.mac\.host\.internal\:9200\/";
  DOCKER_URL_LINUX="localhost\:9200\/";
  if [[ "$OSTYPE" == "darwin"* ]]; then
          echo $DOCKER_URL_MAC;
  elif [[ "$OSTYPE" == "cygwin" ]]; then
          # POSIX compatibility layer and Linux environment emulation for Windows
          echo $DOCKER_URL_WINDOWS;
  elif [[ "$OSTYPE" == "msys" ]]; then
          # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
          echo $DOCKER_URL_WINDOWS;
  elif [[ "$OSTYPE" == "win32" ]]; then
          # I'm not sure this can happen.
          echo $DOCKER_URL_WINDOWS;
  else
          echo $DOCKER_URL_LINUX;
  fi
}

function setElasticUrl() {
  ES_API_DEFAULT=$(getDockerUrl);
  ES_AUTH_DEFAULT="";
  ES_INDEX="clouddocs-"$REPO_NAME"-dev";

  ES_API=${ES_API:-$ES_API_DEFAULT};
  ES_AUTH=${ES_AUTH:-$ES_AUTH_DEFAULT};
  SK_INDEXES=${SK_INDEXES:-$ES_INDEX};

  echo "[DEBUG] ES_AUTH="$ES_AUTH;
  echo "[DEBUG] ES_API="$ES_API;

  if [[ "$ES_API" != "$ES_API_DEFAULT" ]]; then
    echo "Running in production mode";
    if [[ -z "$ES_AUTH" ]]; then
      echo "[WARN] No provided ES authentication. Setting to http";
      ES_INDEX_URL="http\:\/\/"$ES_API;
      SK_ES_URL=$ES_INDEX_URL$SK_INDEXES;
    else
      ES_INDEX_URL="https\:\/\/"$ES_AUTH"\@"$ES_API;
      SK_ES_URL="https\:\/\/"$ES_API$SK_INDEXES;
    fi
  else
    echo "Running in development mode";
    ES_INDEX_URL="http\:\/\/"$ES_API;
    SK_ES_URL=$ES_INDEX_URL$SK_INDEXES;
  fi

  sed -i 's/url\:\s*\"localhost\:9200\"/url\: \"'$ES_INDEX_URL'\"/g' ./_config.yml
  sed -i 's/index\_name\:\s*.*/index\_name\: \"'$ES_INDEX'\"/g' ./_config.yml
  sed -i 's/REPO\_URL/'$REPO_NAME'/g' ./webpack/components/Search.js
  sed -i 's/ES\_AUTH/\"'$ES_AUTH'\"/g' ./webpack/components/Search.js
  sed -i 's/SK\_ES\_URL/\"'$SK_ES_URL'\"/g' ./webpack/components/Search.js
}

function setLocalPort() {
  if [[ -z "$JEKYLL_PORT" ]]; then
    echo "The provided port is empty";
    exit
  fi
  echo "Setting local port to: $JEKYLL_PORT";
  sed -i 's/4000/'$JEKYLL_PORT'/g' ./_config.yml
  sed -i 's/4000/'$JEKYLL_PORT'/g' ./_config.docker.yml
}

function setLocalSiteUrl() {
  JEKYLL_URL="cloudtest\.netapp\.com";
  echo "Setting site url to: "$JEKYLL_URL;
  sed -i 's/^url\: .*/url\: \"'$JEKYLL_URL'\"/g' ./_config.yml
}

function build() {
  mkdir -p build;
  rm -rf build;

  mkdir -p /tmp/gitbuild/
  cp -rf ./* /tmp/gitbuild/

  mkdir -p build;

  mv /tmp/gitbuild/* ./build/
  rm -rf /tmp/gitbuild/

  # Copy files in as dependencies
  cp -rf ../jekyll/* build/
  mv build/sidebar.yml build/_data/sidebars/
  cd build
  setBaseUrl;
  setLocalPort;
  setNSSProduct;
  setElasticUrl;
  # setLocalSiteUrl;
}

function run() {
  echo "Building the content";
  build;

  echo "Starting the local server";
  restart;
}

function_exists() {
  declare -f -F $1 > /dev/null
  return $?
}

if [ $# -lt 1 ]
then
  echo "Usage : $0 start|stop|restart "
  exit
fi

# Set Base URL
if [[ -z "$REPO_NAME" ]]; then
  echo "The provided repository name is empty";
  exit
fi
JEKYLL_BASEURL="\/"$REPO_NAME;

case "$1" in
  start)    function_exists start && start
          ;;
  stop)  function_exists stop && stop
          ;;
  restart)  function_exists restart && restart
          ;;
  run)  function_exists run && run
          ;;
  build)  function_exists build && build
          ;;
  *)      echo "Invalid command - Valid->run|build|start|stop|restart"
          ;;
esac
