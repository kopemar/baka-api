#!/bin/bash

set -e
rm -f /baka-api/tmp/pids/server.pid
exec "$@"