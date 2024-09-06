
cd /usr/local/Cellar/postgresql@16/16.4/bin
# Original filename
original_filename="backup.sql"

# Generate timestamp (format: YYYYMMDD_HHMMSS)
timestamp=$(date +"%Y%m%d_%H%M%S")

# Append timestamp to the filename
new_filename="${original_filename%.*}_${timestamp}.${original_filename##*.}"

# Perform your operation using the new filename
echo "New filename: $new_filename"

PGPASSWORD=123456 ./pg_dump -U postgres -p 5433 -d Contracts > /Users/razvanmustata/Projects/contracts/backend/bck_db/$new_filename
