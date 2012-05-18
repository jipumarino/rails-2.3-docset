version=`date +'%Y%m%d%H%M'`
tar --exclude='.DS_Store' -czf feed/Ruby\ on\ Rails\ 2.3.tgz Ruby\ on\ Rails\ 2.3.docset
cat > feed/Ruby\ on\ Rails\ 2.3.xml <<FEED_XML
<entry>
    <version>$version</version>
    <url>https://github.com/jipumarino/rails-2.3-docset/blob/master/feed/Ruby%20on%20Rails%202.3.tgz</url>
</entry>
FEED_XML

