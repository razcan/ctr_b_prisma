cd /usr/local/Cellar/libpq/16.2_1/bin/
# Original filename
original_filename="backup.sql"

# Generate timestamp (format: YYYYMMDD_HHMMSS)
timestamp=$(date +"%Y%m%d_%H%M%S")

# Append timestamp to the filename
new_filename="${original_filename%.*}_${timestamp}.${original_filename##*.}"

# Perform your operation using the new filename
echo "New filename: $new_filename"

PGPASSWORD=123456 ./pg_dump -U sysadmin -d contracte > /Users/razvanmustata/Projects/contracts/backend/bck_db/$new_filename
