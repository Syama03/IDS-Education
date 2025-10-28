#!/usr/local/bin/bash_vulnerable

echo "Content-type: text/plain"
echo ""
echo "This is the vulnerable CGI script."
echo "Your user agent is: $HTTP_USER_AGENT"
