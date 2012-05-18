#!/usr/bin/env ruby

require 'find'
require 'nokogiri'
require 'cgi'

resources_dir = File.dirname(__FILE__)+'/Rails2.3.docset/Contents/Resources/'
documents_dir = resources_dir+'Documents'

$tokens_file = open(resources_dir+'Tokens.xml', 'w')
$tokens_file.puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Tokens version=\"1.0\">";

paths = Find.find(documents_dir)
paths = paths.select{|path| path =~ /\.html$/}

paths.map do |path|
  dom = Nokogiri::HTML(open path)
  file = path.gsub(/^.*\/Resources\/Documents\//,"")   
  title = dom.at_css("title").text
  type = 'cl'
  next if title =~ /404 not found/i
  type_span = dom.at_css('.type')
  next if type_span.nil?
  type_spam = type_span.text
  type = 'cat' if type_span == 'Module'
  methods = dom.css('a')
  methods.each do |method|
    href = method['href']
    if href =~ /^#M/
      mtype = 'instm' #TODO: class vs instance methods
      anchor = href[1,href.size-1]
      method_name = "#{title}::#{method.text}"
      method_name = CGI.escapeHTML(method_name)
      $tokens_file.puts "<File path=\"#{file}\"><Token><TokenIdentifier>//apple_ref/cpp/#{mtype}/#{method_name}</TokenIdentifier><Anchor>#{anchor}</Anchor></Token></File>\n"
    end
  end

  title = CGI.escapeHTML(title)

  $tokens_file.puts "<File path=\"#{file}\"><Token><TokenIdentifier>//apple_ref/cpp/#{type}/#{title}</TokenIdentifier></Token></File>";
end

$tokens_file.puts "</Tokens>"

#TODO: constantes
# @constants = $dom->getElementsByClassName("attr-name");
#   foreach $const(@constants)
#   {
#     $constName = $title."::".$const->innerText;
#     $parentText = $const->parentNode->parentNode->parentNode->previousSibling->previousSibling->innerText;
#     if($parentText =~ /Attributes/)
#     {
#       $ctype = "Attribute";
#     }
#     elsif($parentText =~ /Constants/)
#     {
#       $ctype = "clconst";
#     }
#     else
#     {
#       print "Couldn't find type for ".$constName." in ".$file."\n";
#     }

#     $constName =~ s/</&lt;/g;
#     $constName =~ s/>/&gt;/g;
#     $constName =~ s/&/&amp;/g;
#     $constName =~ s/"/&quot;/g;
#     $a = $dom->createElement("a");
#     $a->setAttribute("name", uri_escape_utf8($const->innerText));
#     $const->appendChild($a);
#     print TOKENS "<File path=\"".$file."\"><Token><TokenIdentifier>//apple_ref/cpp/".$ctype."/".$constName."</TokenIdentifier><Anchor>".uri_escape_utf8($const->innerText)."</Anchor></Token></File>\n";
#     #print $const->innerText."\n";
#   }
#   open(FILE, ">$fullFile");
#   print FILE $dom->innerHTML;
#   close(FILE);
