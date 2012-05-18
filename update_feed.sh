version=`date +'%Y%m%d%H%M'`
tar --exclude='.DS_Store' -czf feed/Ruby\ on\ Rails\ 2.3.tgz Ruby\ on\ Rails\ 2.3.docset
sed -e "s/VERSION/$version/" feed/Ruby\ on\ Rails\ 2.3.xml.template > feed/Ruby\ on\ Rails\ 2.3.xml