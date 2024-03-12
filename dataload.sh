#!/bin/bash

# Fetch environment variables
DB_HOST=$(echo "$DB_HOST" | awk -F: '{print $1}')
DB_NAME=$DB_NAME
DB_PORT=$DB_PORT
DB_USER=$DB_USER
DB_PW=$DB_PW

export DB_HOST=$DB_HOST

# List of SQL files to execute
SQL_FILES=(
"/home/ubuntu/fluwd_automation/acl_project/mysql/user_db_dump/001_user_db_django_content_type.sql" 
"/home/ubuntu/fluwd_automation/acl_project/mysql/user_db_dump/002_user_db_django_migrations.sql"
"/home/ubuntu/fluwd_automation/acl_project/mysql/user_db_dump/003_user_db_django_session.sql"
"/home/ubuntu/fluwd_automation/acl_project/mysql/user_db_dump/004_user_db_auth_user.sql"
"/home/ubuntu/fluwd_automation/acl_project/mysql/user_db_dump/005_user_db_auth_group.sql"
"/home/ubuntu/fluwd_automation/acl_project/mysql/user_db_dump/006_user_db_auth_permission.sql"
"/home/ubuntu/fluwd_automation/acl_project/mysql/user_db_dump/007_user_db_auth_group_permissions.sql"
"/home/ubuntu/fluwd_automation/acl_project/mysql/user_db_dump/008_user_db_auth_user_user_permissions.sql"
"/home/ubuntu/fluwd_automation/acl_project/mysql/user_db_dump/009_user_db_admin_app_record.sql"
"/home/ubuntu/fluwd_automation/acl_project/mysql/user_db_dump/010_user_db_auth_user_groups.sql"
"/home/ubuntu/fluwd_automation/acl_project/mysql/user_db_dump/011_user_db_django_admin_log.sql")

# Check if any of the variables are empty
if [ -z "$DB_USER" ] || [ -z "$DB_PW" ] || [ -z "$DB_HOST" ] || [ -z "$DB_NAME" ]; then
  echo "Error: One or more database environment variables are not set."
  exit 1
fi
sudo mysql -u "$DB_USER" -p"$DB_PW" -h "$DB_HOST" -e "create database user_db;"

# Iterate over the SQL files and execute them

for file in "${SQL_FILES[@]}"; do
    echo "Executing $file..."
    sudo mysql -u "$DB_USER" -p"$DB_PW" -h "$DB_HOST" < "$file"
done

echo "All scripts executed successfully."