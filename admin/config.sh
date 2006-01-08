#/bin/sh

# Miscellaneous configuration items go here.  You probably want to customise
# these to suit your installation.

# These could be moved into DBDefs.pm, so that ./admin/ShowDBDefs would do the
# whole lot in one go; the only reason they're here is that these things
# are, so far, only used by /bin/sh scripts, not Perl.

# Certain cron processes mail their output off separately if they fail.  This
# is where they get mailed to.
ADMIN_EMAILS="rob dave lazarus@broadpark.no"

# Were to put database exports, and replication data, for public consumption;
# who should own them, and what mode they should have.
FTP_DATA_DIR=/var/ftp/pub/musicbrainz/data
FTP_USER=root
FTP_GROUP=ftp
FTP_DIR_MODE=755
FTP_FILE_MODE=644

# Where to back things up to, who should own the backup files, and what mode
# those files should have.
# The backups include a full database export, and all replication data.
BACKUP_DIR=/home/mbbackup
BACKUP_USER=mbbackup
BACKUP_GROUP=root
BACKUP_DIR_MODE=700
BACKUP_FILE_MODE=600

# Other things to be backed up every night.  Omit the leading slash.
# Set these to empty to disable these backups.
CVS_DIR=var/cvs
WIKI_DIRS="var/mbwiki var/website/oldwiki.musicbrainz.org var/website/syswiki.musicbrainz.org var/website/wiki.musicbrainz.org var/website/wikidocs.musicbrainz.org usr/share/moin var/website/blog.musicbrainz.org"
APACHE_CONFIG_DIRS="usr/local/perl58/apache/conf usr/local/perl58/apache2/conf"
MAILMAN_DIR=usr/local/mailman

# All executables are assumed to be on your PATH, so add any unusual
# requirements in here.
PATH=/usr/local/pgsql/bin:/usr/local/bin:$PATH
export PATH

# eof
