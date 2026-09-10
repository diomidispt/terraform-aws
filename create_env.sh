#!/bin/bash

# Ask for environment
echo "Available environments:"
ENVIRONMENTS=( $(ls ./envs) )
select ENVIRONMENT in "${ENVIRONMENTS[@]}"; do
	[ -n "$ENVIRONMENT" ] && break
	echo "Invalid selection."
done

# Ask for account after environment
echo "Available accounts:"
ACCOUNTS=( $(ls ./common/accounts) )
select ACCOUNT_NAME in "${ACCOUNTS[@]}"; do
	[ -n "$ACCOUNT_NAME" ] && break
	echo "Invalid selection."
done

# Ask for region after account
echo "Available regions:"
REGION_FILES=( $(ls ./common/accounts/$ACCOUNT_NAME/region.*.tfvars) )
REGION_NAMES=()
for file in "${REGION_FILES[@]}"; do
	REGION_NAMES+=( $(basename "$file" | sed -E 's/region\.([^.]+)\.tfvars/\1/') )
done
select REGION_NAME in "${REGION_NAMES[@]}"; do
	[ -n "$REGION_NAME" ] && break
	echo "Invalid selection."
done
REGION_FILE="region.$REGION_NAME.tfvars"

# Ask for unique identifier (optional)
read -p "Enter a unique identifier (optional, press Enter to skip): " UNIQUE_ID

# Ask for stage
STAGES=(DEV STAG PROD)
echo "Select the stage:"
select STAGE in "${STAGES[@]}"; do
	[ -n "$STAGE" ] && break
	echo "Invalid selection."
done


# Construct the target directory path
if [ -n "$UNIQUE_ID" ]; then
	TARGET_DIR="./envs/$ENVIRONMENT/${ACCOUNT_NAME}-${REGION_NAME}-${ENVIRONMENT}-${UNIQUE_ID}-${STAGE}"
else
	TARGET_DIR="./envs/$ENVIRONMENT/${ACCOUNT_NAME}-${REGION_NAME}-${ENVIRONMENT}-${STAGE}"
fi
mkdir -p "$TARGET_DIR"

# Create common symlinks
ln -s ../common/main.tf "$TARGET_DIR/common.main.tf"
ln -s ../common/provider.tf "$TARGET_DIR/common.provider.tf"
ln -s ../common/variables.tf "$TARGET_DIR/common.variables.tf"

# Create account symlink
ln -s "../../../common/accounts/$ACCOUNT_NAME/account.tfvars" "$TARGET_DIR/common.account.auto.tfvars"

# Create region symlink
ln -s "../../../common/accounts/$ACCOUNT_NAME/$REGION_FILE" "$TARGET_DIR/common.region.auto.tfvars"


# Create state.tf with backend config
if [ -n "$UNIQUE_ID" ]; then
	cat > "$TARGET_DIR/state.tf" <<EOF
terraform {
	backend "s3" {
		region         = "us-east-1"
		bucket         = "sauron-cicd-tfstate"
		key            = "$ENVIRONMENT/${ACCOUNT_NAME}-${REGION_NAME}-${ENVIRONMENT}-${UNIQUE_ID}-${STAGE}/terraform.tfstate"
		dynamodb_table = "sauron-cicd-tfstate"
		encrypt        = "true"
	}
}
EOF
else
	cat > "$TARGET_DIR/state.tf" <<EOF
terraform {
	backend "s3" {
		region         = "us-east-1"
		bucket         = "sauron-cicd-tfstate"
		key            = "$ENVIRONMENT/${ACCOUNT_NAME}-${REGION_NAME}-${ENVIRONMENT}-${STAGE}/terraform.tfstate"
		dynamodb_table = "sauron-cicd-tfstate"
		encrypt        = "true"
	}
}
EOF
fi

# Create empty terraform.tfvars file
touch "$TARGET_DIR/terraform.tfvars"
terraform fmt -recursive "$TARGET_DIR"

echo "Symlinks and files created in $TARGET_DIR"
