#!/bin/Bash

function start() {
  docker-compose build --no-cache;
  #docker-compose start -d;
  docker-compose up -d;
  sleep 10s;
}

function stop() {
  #docker-compose stop;
  #docker-compose rm -v;
  docker-compose down -v;
  sleep 5s;
}

function getStatus() {
  docker ps -a;
}

function restart() {
  stop;
  start;
}

function setBaseUrl() {
  if [[ -z "$JEKYLL_BASEURL" ]]; then
    echo "The provided baseurl is empty";
    exit
  fi
  echo "Setting site baseurl to: $JEKYLL_BASEURL";
  sed -i 's/\/jekyll/'$JEKYLL_BASEURL'/g' ./_config.yml
}

function setNSSProduct() {
  if [[ -z "$NSS_PRODUCT" ]]; then
    echo "[WARN] The NSS Product Name is empty";
  else
    echo "Setting NSS Product Name to: $NSS_PRODUCT";
    echo "nss_product: $NSS_PRODUCT" >> ./_config.yml
    #sed -i "s/^nss_product\: .*/nss_product\: $NSS_PRODUCT/g" ./_config.yml
  fi
}

function setLocalPort() {
  if [[ -z "$JEKYLL_PORT" ]]; then
    echo "The provided port is empty";
    exit
  fi
  echo "Setting local port to: $JEKYLL_PORT";
  sed -i 's/4000/'$JEKYLL_PORT'/g' ./_config.yml
  sed -i 's/4000/'$JEKYLL_PORT'/g' ./_config.docker.yml
  sed -i 's/4000/'$JEKYLL_PORT'/g' ./docker-compose.yml
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
  *)      echo "Invalid command - Valid->start|stop|restart"
          ;;
esac
