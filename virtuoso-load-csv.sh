#!/bin/bash

# The script traverses the first-level subfolders of the "data-source-directory" and uploads the CSV files it finds into corresponding WebDAV Linked Data Import (LDI) folders on the Fusepool Virtuoso instance. The CSV files are automatically sponged into RDF, and the resulting RDF for the folder (which includes the RDF triples from all sponged CSV files it contains) is downloaded back into the source folder.

USAGE="Usage: `basename $0` data-source-directory username password"

if [ $# -lt 3 ]
	then
	echo "$USAGE"
	exit 1
fi

# username, password and password-hash for access to Virtuoso
user=$2
pass=$3
passhash=`echo -n ${user}${pass} | sha1sum | cut -d ' ' -f 1` # sha1 password-hash from the username+password

# comma-separated IDs of the Sponger cartridges we want to use
cartridges="18" # the ID of the CSV cartridge

start=`pwd`
directory="$1"
cd $directory

for dir in *
do
	if [ -d $dir ]
		then
		cd $dir
		echo ""		
		echo "Working with directory $dir"

		webdavfolder="http://fusepool.openlinksw.com/DAV/home/dba/fusepool_data_import/${dir}" # the location of the WebDAV LDI folder to be created
		webdavfolderrelative="/DAV/home/dba/fusepool_data_import/${dir}" # the relative path to the WebDAV LDI folder

		echo ""
		echo "Creating a corresponding WebDAV directory for $dir at $webdavfolder"
		curl -i "http://fusepool.openlinksw.com/ods/api/briefcase.collection.create?path=${webdavfolderrelative}&user_name=${user}&password_hash=${passhash}&permissions=111111111RR&det=LDI&det_graph=${webdavfolder}&det_base=${webdavfolder}&det_sponger=on&det_cartridges=${cartridges}" # create a WebDAV LDI folder on Virtuoso

		for file in *
		do
			if [ -f $file ]
				then
				ext=`echo $file | awk -F. '{ print $NF }' | tr [A-Z] [a-z]` # get the file extension, and put it in lower case
				if [ $ext == "csv" ] # the script works with CSV files
					then					
					echo ""
					echo "--- Uploading CSV to Virtuoso ---"
					echo "Uploading file $file to ${webdavfolder}/"
					curl -T $file ${webdavfolder}/ -u ${user}:${pass} # upload the CSV to the WebDAV LDI folder on Virtuoso
					sleep 10 # wait for a reply from Virtuoso, for larger files
					echo ""		
				fi
			fi
		done

		# wait for a little while, while the RDF file is generated
		echo ""
		echo "Waiting for the RDF file to be generated ..."
		sleep 10

		# download the generated RDF file from the WebDAV LDI folder on Virtuoso
		echo ""
		webdavfolderrdf=`echo ${webdavfolder}.RDF | tr [:/] _` # add the .RDF file extension and replace : and / chars with _
		echo "--- Downloading RDF from Virtuoso ---"
		echo "Downloading file ${webdavfolder}/${webdavfolderrdf} to $dir"
		wget ${webdavfolder}/${webdavfolderrdf} # download the generated RDF file from the WebDAV folder

		cd ..
	fi
done

echo ""
cd $start