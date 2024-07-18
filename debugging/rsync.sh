#!/bin/bash

# Note: Adjust rsync flags as needed for your specific requirements

#### Info ####
## For AutoBackup,save in /etc/cron.daily/backup
##link# curl https://gist.github.com/hiranp/06d74c84c4efb1ce7478b9471261cd54.js ~/sync_backup.sh | chmod +x ~/sync_backup.sh | cp -r ~/sync_backup.sh /etc/cron.daily/sync_backup | chmod +x /etc/cron.daily/sync_backup;

##$ rsync -a --delete --quiet $FDIR $BDIR;
##$ rsync -aAXv --delete-after --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} / /mnt/backup;
##$ rsync -aAXv --delete-after --exclude-from="skipme.txt" / /mnt/backup;

# Source and destination for rsync
SOURCE_DIR='/srv/data/'
DESTINATION='myserver.com:/srv/data/'
# Default exclude patterns file
EXCLUDE_FILE='/home/hiran/exclude_me.txt'
# Number of parallel processes
PARALLEL_PROCESSES=4

# Check for --exclude-from argument
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --exclude-from) EXCLUDE_FILE="$2"; shift ;;
    esac
    shift
done

# Ensure the destination directory exists (if checking remote, this needs SSH command execution)
if ! ssh myserver.com "[ -d $DESTINATION ]"; then
    echo "Destination directory does not exist. Attempting to create it."
    ssh myserver.com "mkdir -p $DESTINATION"
    if [ $? -ne 0 ]; then
        echo "Failed to create destination directory. Exiting."
        exit 1
    fi
fi

# Use xargs for parallel rsync execution
find $SOURCE_DIR -type d -print0 | xargs -0 -n1 -P$PARALLEL_PROCESSES -I% rsync -aAXv --delete-after --exclude-from="$EXCLUDE_FILE" "%" "$DESTINATION" || {
    echo "An error occurred during rsync operation."
    exit 1
}

echo "Backup completed successfully."