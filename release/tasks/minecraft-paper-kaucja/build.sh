#!/bin/bash
set -euo pipefail
cd /app
mkdir -p build/classes
find build/classes -type f -delete
CLASSPATH=$(find /opt/paper/libraries /opt/paper/versions -name '*.jar' -print | paste -sd:)
find src/main/java -name '*.java' -print > build/sources.txt
javac -encoding UTF-8 --release 25 -cp "$CLASSPATH" -d build/classes @build/sources.txt
cp -R src/main/resources/. build/classes/
jar cf build/Deployment.jar -C build/classes .
