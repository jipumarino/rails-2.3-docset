$docPath = "/Users/bogdan/Desktop/Rails/Contents/Resources/Documents/api.rubyonrails.org/classes";

use HTML::DOM;
use File::Find;
use URI::Escape;

$| = 1;

open(TOKENS, ">Tokens.xml");
print TOKENS "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Tokens version=\"1.0\">";

# find( \&parseHTML, $docPath);

print TOKENS "</Tokens>";
close(TOKENS);

sub parseHTML
{
	if(/\.html$/)
	{
		$file = "$File::Find::name$/";
		chomp($file);
		$dom = new HTML::DOM;
		$dom->parse_file($file);
		$fullFile = $file;
		$file =~ s/\/Users\/bogdan\/Desktop\/Rails\/Contents\/Resources\/Documents\///;
		$title = $dom->getElementsByTagName("title")->[0]->innerText;
		$type = "cl";
		if($title =~ /404 not found/i)
		{
			return;
		}
		$typeSpan = $dom->getElementsByClassName("type")->[0]->innerText;
		if($typeSpan =~ /Module/)
		{
			$type = "cat";
		}
		
		@methods = $dom->getElementsByTagName("a");
		foreach $method(@methods)
		{
			$href = $method->getAttribute("href");
			if(substr (lc $href, 0, 7) =~ /#method/i)
			{
				if(substr (lc $href, 0, 9) =~ /#method-c/i)
				{
					$mtype = "instm";
				}
				elsif(substr (lc $href, 0, 9) =~ /#method-i/i)
				{
					$mtype = "clm";
				}
				$anchor = substr($href, 1, length($href)-1);
				$methodName = $title."::".$method->innerText;
				if(!grep {$_ eq $methodName.$mtype} @ADDED) 
				{
					$ADDED[++$#ADDED] = $methodName.$mtype;
				}
				else
				{
					print "DUPLICATE FOUND FOR $methodName at $file\n";
					return;
				}
				$methodName =~ s/</&lt;/g;
				$methodName =~ s/>/&gt;/g;
				$methodName =~ s/&/&amp;/g;
				$methodName =~ s/"/&quot;/g;
				print TOKENS "<File path=\"".$file."\"><Token><TokenIdentifier>//apple_ref/cpp/".$mtype."/".$methodName."</TokenIdentifier><Anchor>".$anchor."</Anchor></Token></File>\n";
				#print $methodName."\n";
			}
		}
		
		@constants = $dom->getElementsByClassName("attr-name");
		foreach $const(@constants)
		{
			$constName = $title."::".$const->innerText;
			$parentText = $const->parentNode->parentNode->parentNode->previousSibling->previousSibling->innerText;
			if($parentText =~ /Attributes/)
			{
				$ctype = "Attribute";
			}
			elsif($parentText =~ /Constants/)
			{
				$ctype = "clconst";
			}
			else
			{
				print "Couldn't find type for ".$constName." in ".$file."\n";
			}
			if(!grep {$_ eq $constName.$ctype} @ADDED) 
			{
				$ADDED[++$#ADDED] = $constName.$ctype;
			}
			else
			{
				print "DUPLICATE FOUND FOR $title at $file\n";
				return;
			}
			$constName =~ s/</&lt;/g;
			$constName =~ s/>/&gt;/g;
			$constName =~ s/&/&amp;/g;
			$constName =~ s/"/&quot;/g;
			$a = $dom->createElement("a");
			$a->setAttribute("name", uri_escape_utf8($const->innerText));
			$const->appendChild($a);
			print TOKENS "<File path=\"".$file."\"><Token><TokenIdentifier>//apple_ref/cpp/".$ctype."/".$constName."</TokenIdentifier><Anchor>".uri_escape_utf8($const->innerText)."</Anchor></Token></File>\n";
			#print $const->innerText."\n";
		}
		open(FILE, ">$fullFile");
		print FILE $dom->innerHTML;
		close(FILE);

		if(!grep {$_ eq $title.$type} @ADDED) 
		{
			$ADDED[++$#ADDED] = $title.$type;
		}
		else
		{
			print "DUPLICATE FOUND FOR $title at $file\n";
			return;
		}
		$title =~ s/</&lt;/g;
		$title =~ s/>/&gt;/g;
		$title =~ s/&/&amp;/g;
		$title =~ s/"/&quot;/g;
		#print $title." -> $type\n";
		print TOKENS "<File path=\"".$file."\"><Token><TokenIdentifier>//apple_ref/cpp/".$type."/".$title."</TokenIdentifier></Token></File>\n";
	}
}