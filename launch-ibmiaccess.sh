#!/bin/sh
JAVA_BIN=/usr/lib/sdk/openjdk/bin/java
exec "$JAVA_BIN" -jar /app/IBMiAccess_v1r1/acsbundle.jar "$@"
