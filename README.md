# eXo Docker container

[![Docker Stars](https://img.shields.io/docker/stars/exoplatform/exo.svg?maxAge=2592000)]() - [![Docker Pulls](https://img.shields.io/docker/pulls/exoplatform/exo.svg?maxAge=2592000)]()

The aim of this repository is to give the configuration to run eXo Platform in a Docker containers for production purpose.

# Supported databases

Currently we only support `MySQL`.

## Configuration

The following environment variables must be passed to the container in order to work :


|    VARIABLE              |  MANDATORY  |   DEFAULT VALUE          |  DESCRIPTION
|--------------------------|-------------|--------------------------|----------------
| EXO_DB_TYPE | NO | `mysql` | we currently only support mysql
| EXO_DB_NAME | NO | `exo` | the name of the database / schema to use
| EXO_DB_USER | NO | `exo` | the username to connect to the database
| EXO_DB_PASSWORD | YES | - | the password to connect to the database
| EXO_DB_HOST | NO | `mysql` | the host to connect to the database server
| EXO_DB_PORT | NO | `3306` | the port to connect to the database server
| EXO_DATA_DIR | NO | `/srv/exo` | the directory to store eXo Platform data
| EXO_CHAT_DB_HOSTNAME | NO | `mongo` | the host to connect to the chat server database
| EXO_CHAT_DB_PORT | NO | `27017` | the port of the chat server database
| EXO_ES_EMBEDDED | NO | `true` | does the embedded elasticsearch should be started
| EXO_ES_HOST | NO | `localhost` | the host to connect to elasticsearch
| EXO_ES_PORT | NO | `9200` | the port to connect to elasticsearch

## License

The eXo Platform license file location must be `/etc/exo/license.xml`
