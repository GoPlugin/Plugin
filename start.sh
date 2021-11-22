#!/bin/bash

echo Running start script... &&
plugin local import /keys/$KEY_NAME &&
plugin local node -d -p /password.txt -a /apicredentials
