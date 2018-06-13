#!/bin/Bash
echo "Starting Jekyll"
cd /src/
npm run-script build
jekyll serve -H 0.0.0.0
echo "Server is ready"
tail -f /dev/null
