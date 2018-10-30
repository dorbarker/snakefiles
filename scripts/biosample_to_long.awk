#!/usr/bin/awk -f

BEGIN {
	FS="=";
	OFS="\t";
}
NR==1 {
	print "biosample", "variable", "value";
}
/=/ {
	gsub("\"", "", $0);
	gsub(/\//, "", $1);
	print FILENAME, $1, $2;
}
