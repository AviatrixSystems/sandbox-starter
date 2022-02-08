#!/bin/bash
avx_role_app=$(aws iam get-role --role-name aviatrix-role-ec2 | jq -r .Role.RoleName)
echo -n "{\"role_exists\":\"${avx_role_app}\"}"
