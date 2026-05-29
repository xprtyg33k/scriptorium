#!/usr/bin/env bash
# Phase 7: AWS CLI profile config (structure only — credentials must be added manually)
set -euo pipefail

echo "==> Phase 7: AWS CLI config"

mkdir -p ~/.aws

# Write config (no credentials here — see Phase 0 / README for credentials)
cat > ~/.aws/config << 'AWSCONFIG'
[profile experity-dev]
region = us-east-1
output = json

[profile enterprise-dev]
region = us-east-1
output = json
AWSCONFIG

echo "--> ~/.aws/config written with profiles: experity-dev, enterprise-dev"
echo ""
echo "    IMPORTANT: ~/.aws/credentials is NOT created by this script."
echo "    Copy it from your old machine or recreate it:"
echo ""
echo "    [experity-dev]"
echo "    aws_access_key_id = <your key>"
echo "    aws_secret_access_key = <your secret>"
echo ""
echo "    [enterprise-dev]"
echo "    aws_access_key_id = <your key>"
echo "    aws_secret_access_key = <your secret>"
echo ""
echo "    Or use: aws configure sso  (if your org uses SSO)"
echo ""
echo "==> Phase 7 complete."
