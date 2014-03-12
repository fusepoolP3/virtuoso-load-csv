virtuoso-load-csv.sh
=================

A shell script for uploading CSV files to WebDAV folders on a Virtuoso instance, and downloading the sponged RDF content as .rdf files.

Script usage:
	
	virtuoso-load-csv.sh data-source-directory username password

The script traverses the first-level subfolders of the "data-source-directory" and uploads the CSV files they contain into corresponding WebDAV Linked Data Import (LDI) folders on the Fusepool Virtuoso instance. The username and password arguments are used for authentication at the Virtuoso instance.

The uploaded CSV files are automatically sponged into an RDF graph on the Virtuoso instance and the resulting RDF file for the folder (which includes the RDF triples from all sponged CSV files it contains) is downloaded back into the source folder.
