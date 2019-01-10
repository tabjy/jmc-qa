#!/bin/bash
source $(dirname "$0")/config.sh

# if a jmc folder already exists, remove it prior to cloning
if [ -d $JMC_ROOT ]; then
    rm -r $JMC_ROOT;
fi

# clone the jmc repo
hg clone $JMC_REPO $JMC_ROOT || { exit 1; };

# setup the p2 repository
mvn p2:site -f $JMC_THIRD_PARTY/pom.xml || { exit 1; };

# run the jetty server in the background
mvn jetty:run -f $JMC_THIRD_PARTY/pom.xml &
jetty_pid=$!;

# build jmc-core
mvn clean install -f $JMC_CORE/pom.xml || { exit 1; };

# build jmc
cd $JMC_ROOT;
mvn verify || { kill $jetty_pid; exit 1; };

# kill the jetty process
kill $jetty_pid;
