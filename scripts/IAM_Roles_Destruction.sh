#!/bin/bash


roles=$(aws iam list-roles --query 'Roles[?contains(RoleName, `metabase`)].RoleName' --output text)

for role in $roles; do
    echo "=== Processing role: $role ==="
    

    inline_policies=$(aws iam list-role-policies --role-name $role --query 'PolicyNames' --output text)
    for policy in $inline_policies; do
        echo "Deleting inline policy: $policy"
        aws iam delete-role-policy --role-name $role --policy-name $policy
    done
    

    attached_policies=$(aws iam list-attached-role-policies --role-name $role --query 'AttachedPolicies[].PolicyArn' --output text)
    for policy_arn in $attached_policies; do
        echo "Detaching policy: $policy_arn"
        aws iam detach-role-policy --role-name $role --policy-arn $policy_arn
    done
    

    instance_profiles=$(aws iam list-instance-profiles-for-role --role-name $role --query 'InstanceProfiles[].InstanceProfileName' --output text)
    for profile in $instance_profiles; do
        echo "Removing role from instance profile: $profile"
        aws iam remove-role-from-instance-profile --instance-profile-name $profile --role-name $role
        echo "Deleting instance profile: $profile"
        aws iam delete-instance-profile --instance-profile-name $profile
    done
    
    echo "Deleting role: $role"
    aws iam delete-role --role-name $role
done