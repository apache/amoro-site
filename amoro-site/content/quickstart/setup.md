---
title: "Quickstart Setup"
url: quickstart-setup
disableSidebar: true
---
# Setup

This guide describes two ways to deploy the Amoro demo environment: using docke-compose or release packages. If you want to deploy by compiling the source code, please refer to [Deployment](/docs/latest/deployment/).

## Setup from Docker-Compose

The fastest way to deploy a [Quick Demo](/quick-demo/) environment is to use docker-compose.

### Requirements

Before starting to deploy Amoro based on Docker, please make sure that you have installed the docker-compose environment on your host. For information on how to install Docker, please refer to: [Install Docker](https://docs.docker.com/get-docker/).

{{< hint info >}}
It is recommended to perform the operation on Linux or MacOS. If you are using a Windows system, you can consider using WSL2. For information on how to enable WSL2 and install Docker, please refer to [Windows Installation](https://docs.docker.com/desktop/install/windows-install/).
{{< /hint >}}

After completing the Docker installation, please make sure that the docker-compose tool is installed: [Docker-Compose Installation](https://github.com/docker/compose-cli/blob/main/INSTALL.md).

### Bring up demo cluster

Before starting, please prepare a clean directory as the workspace for Amoro Demo deployment, and obtain the Amoro demo deployment script:

```shell
cd <AMORO-WORKSPACE>
wget https://raw.githubusercontent.com/apache/incubator-amoro/master/docker/demo-cluster.sh
```

Execute the following shell command to launch a demo cluster using docker-compose:

```shell
bash demo-cluster.sh start
```

After executing the above command, there will be a `data` directory in the workspace directory for sharing files between different docker containers. You can use the following command to view all the running Docker containers:

```shell
$ docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"

CONTAINER ID   NAMES       STATUS
2a0d326c668f   datanode    Up 1 minutes
8e6b1c36e6ba   namenode    Up 1 minutes
1e11fb8187b3   quickdemo   Up 1 minutes
```


## Setup from binary release

If it is not convenient to install Docker and related tools, you can also deploy the Amoro demo cluster directly through the Amoro release package.

### Requirements

Before starting, please make sure that Java 8 is installed and the JAVA_HOME environment variable is set.
Please make sure that there is no `HADOOP_HOME` or `HADOOP_CONF_DIR` in the environment variables. If there are, please unset these environment variables first.

### Setup AMS

Prepare a clean directory as the workspace for the Amoro demo cluster, and execute the following command to download Amoro and start AMS:

```shell
cd <AMORO-WORKSPACE>

# Rplace version value with the latest Amoro version if needed
export AMORO_VERSION=0.6.0

# Download the binary package of AMS
wget https://github.com/apache/incubator-amoro/releases/download/v${AMORO_VERSION}/amoro-${AMORO_VERSION}-bin.zip

# Unzip the pakage
unzip amoro-${AMORO-VERSION}-bin.zip

# Start AMS by script
cd amoro-${AMORO-VERSION} && ./bin/ams.sh start
```

Access [http://127.0.0.1:1630/](http://127.0.0.1:1630/) with a browser and log in to the system with `admin/admin`. If you can log in successfully, it means that the deployment of AMS is successful.

### Setup Flink environment

Before starting the Quick Demo, you also need to deploy the Flink execution environment. Execute the following command to download the Flink binary distribution package:

```shell
cd <AMORO-WORKSPACE>

# Rplace version value with the latest Amoro version if needed
AMORO_VERSION=0.6.0
ICEBERG_VERSION=1.3.0
FLINK_VERSION=1.15.3
FLINK_MAJOR_VERSION=1.15
FLINK_HADOOP_SHADE_VERSION=2.7.5
APACHE_FLINK_URL=archive.apache.org/dist/flink
MAVEN_URL=https://repo1.maven.org/maven2
FLINK_CONNECTOR_URL=${MAVEN_URL}/org/apache/flink
AMORO_CONNECTOR_URL=${MAVEN_URL}/com/apache/incubator-amoro
ICEBERG_CONNECTOR_URL=${MAVEN_URL}/org/apache/iceberg

# Download FLink binary package
wget ${APACHE_FLINK_URL}/flink-${FLINK_VERSION}/flink-${FLINK_VERSION}-bin-scala_2.12.tgz
# Unzip Flink binary package
tar -zxvf flink-${FLINK_VERSION}-bin-scala_2.12.tgz

cd flink-${FLINK_VERSION}
# Download Flink Hadoop dependency
wget ${FLINK_CONNECTOR_URL}/flink-shaded-hadoop-2-uber/${FLINK_HADOOP_SHADE_VERSION}-10.0/flink-shaded-hadoop-2-uber-${FLINK_HADOOP_SHADE_VERSION}-10.0.jar
# Download Flink Aoro Connector
wget ${AMORO_CONNECTOR_URL}/amoro-flink-runtime-${FLINK_MAJOR_VERSION}/${AMORO_VERSION}/amoro-flink-runtime-${FLINK_MAJOR_VERSION}-${AMORO_VERSION}.jar
# Download Flink Iceberg Connector
wget ${ICEBERG_CONNECTOR_URL}/iceberg-flink-runtime-${FLINK_MAJOR_VERSION}/${ICEBERG_VERSION}/iceberg-flink-runtime-${FLINK_MAJOR_VERSION}-${ICEBERG_VERSION}.jar

# Copy the necessary JAR files to the lib directory
mv flink-shaded-hadoop-2-uber-${FLINK_HADOOP_SHADE_VERSION}-10.0.jar lib
mv amoro-flink-runtime-${FLINK_MAJOR_VERSION}-${AMORO_VERSION}.jar lib
mv iceberg-flink-runtime-${FLINK_MAJOR_VERSION}-${ICEBERG_VERSION}.jar lib
cp examples/table/ChangelogSocketExample.jar lib
```

Finally, we need to make some modifications to the `flink-conf.yaml` configuration file.

```shell
vim conf/flink-conf.yaml

# Increase the number of slots to run more streaming tasks
taskmanager.numberOfTaskSlots: 4

# Enable checkpointing and to see data changes more quickly, set the checkpoint interval to 5 seconds.
execution.checkpointing.interval: 5s
```