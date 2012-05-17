open(FILE, ">>$ARGV[0]");
print FILE "\n.banner ul.files {display:none}\n";
print "Appended CSS to $ARGV[0]\n";
close(FILE);
