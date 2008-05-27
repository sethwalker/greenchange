/**
 * This is the updated function by Ben Lancaster, based on Jeff Minard's variations on Stuart Langridge's original - http://blog.benlancaster.co.uk/
 * Jeff Minard: http://jrm.cc/
 * Stuart Langridge: http://www.kryogenix.org/
 */
function textile(s) {
    var r = s;
    // quick tags first
    var qtags = [['\\*', 'strong'],
             ['\\?\\?', 'cite'],
             ['\\+', 'ins'],  //fixed
             ['~', 'sub'],   
             ['-', 'del'],   
             ['\\^', 'sup'], // me
             ['@', 'code']];
    for (var i=0;i<qtags.length;i++) {
        var ttag = qtags[i][0]; htag = qtags[i][1];
        var re = new RegExp(ttag+'\\b(.+?)\\b'+ttag,'g');
        var r = r.replace(re,'<'+htag+'>'+'$1'+'</'+htag+'>');
    }
    // underscores count as part of a word, so do them separately
    re = new RegExp('\\b_(.+?)_\\b','g');
    r = r.replace(re,'<em>$1</em>');
	
	//jeff: so do dashes
    //re = new RegExp('[\s\n]-(.+?)-[\s\n]','g');
    //r = r.replace(re,'<del>$1</del>');

    // links
    re = new RegExp('"\\b(.+?)\\(\\b(.+?)\\b\\)":([^\\s]+)','g');
    //r = r.replace(re,'<a href="$3" title="$2">$1</a>');
    //TODO why does the quoting here fail in FF?
    r = r.replace(re,'<a href=$3 title="$2">$1</a>');
    re = new RegExp('"\\b(.+?)\\b":([^\\s]+)','g');
    r = r.replace(re,'<a href="$2">$1</a>');

	// BenL: Various special characters etc
	re = new RegExp('\\(c\\)','g');
	r = r.replace(re,'&copy;');
	re = new RegExp('\\(tm\\)','g');
	r = r.replace(re,'&trade;');
	re = new RegExp('\\(r\\)','g');
	r = r.replace(re,'&reg;');
	re = new RegExp('\\.\\.\\.','g');
	r = r.replace(re,'&#8230;');
	re = new RegExp('"(.+?)"([\\s:,;])','g');
	r = r.replace(re,'&#8220;$1&#8221;$2');
	re = new RegExp('\\-\\-','g');
	r = r.replace(re,'&#8212');
	re = new RegExp(' \\- ','g');
	r = r.replace(re,' &#8212 ');

    // images
    re = new RegExp('!\\b(.+?)\\(\\b(.+?)\\b\\)!','g');
    r = r.replace(re,'<img src="$1" alt="$2">');
    re = new RegExp('!\\b(.+?)\\b!','g');
    r = r.replace(re,'<img src="$1">');
    
    // block level formatting
	
		// Jeff's hack to show single line breaks as they should.
		// insert breaks - but you get some....stupid ones
	    re = new RegExp('(.*)\n([^#\*\n].*)','g');
	    r = r.replace(re,'$1<br />$2');
		// remove the stupid breaks.
	    re = new RegExp('\n<br />','g');
	    r = r.replace(re,'\n');
	
    var lines = r.split('\n');
    var nr = '';
    for (var i=0;i<lines.length;i++) {
        var line = lines[i].replace(/\s*$/,'');
        var changed = 0;
        if (line.search(/^\s*bq\.\s+/) != -1) { 
			line = line.replace(/^\s*bq\.\s+/,'\t<blockquote>')+'</blockquote>'; 
			changed = 1; 
		}
		
		// jeff adds h#.
        if (line.search(/^\s*h[1|2|3|4|5|6]\.\s+/) != -1) { 
	    	re = new RegExp('h([1|2|3|4|5|6])\.(.+)','g');
	    	line = line.replace(re,'<h$1>$2</h$1>');
			changed = 1; 
		}
		
		if (line.search(/^\s*\*\s+/) != -1) { line = line.replace(/^\s*\*\s+/,'\t<liu>') + '</liu>'; changed = 1; } // * for bullet list; make up an liu tag to be fixed later
		if (line.search(/^\s*(\*{2})\s+/) != -1) { line = line.replace(/^\s*\*{2}\s+/,'\t<liiu>') + '</liiu>'; changed = 1; } // ** for nested bullet list
		if (line.search(/^\s*(\*{3})\s+/) != -1) { line = line.replace(/^\s*\*{3}\s+/,'\t<liiiu>') + '</liiiu>'; changed = 1; } // ** for nested bullet list
        if (line.search(/^\s*#\s+/) != -1) { line = line.replace(/^\s*#\s+/,'\t<lio>') + '</lio>'; changed = 1; } // # for numeric list; make up an lio tag to be fixed later
        if (!changed && (line.replace(/\s/g,'').length > 0)) line = '<p>'+line+'</p>';
        lines[i] = line + '\n';
    }
	
    // Second pass to do lists
    var inlist = 0; 
	var listtype = '';
    for (var i=0;i<lines.length;i++) {
        line = lines[i];
        if (inlist && listtype == 'ul' && !line.match(/^\t<li+u/)) { line = '</ul>\n' + line; inlist--; }
        if (!inlist && line.match(/^\t<liu/)) { line = '<ul>' + line; inlist++; listtype = 'ul'; }

        if (inlist && listtype == 'ol' && !line.match(/^\t<lio/)) { line = '</ol>\n' + line; inlist--; }
        if (!inlist && line.match(/^\t<lio/)) { line = '<ol>' + line; inlist++; listtype = 'ol'; }

        if (inlist>1 && listtype == 'ul' && !line.match(/^\t<lii+u>/)) { line = '</ul>\n' + line; inlist--; }
        if (inlist<2 && line.match(/^\t<liiu>/)) { line = '<ul>' + line; inlist++; listtype = 'ul'; }

        if (inlist>2 && listtype == 'ul' && !line.match(/^\t<liii+u>/)) { line = '</ul>\n' + line; inlist--; }
        if (inlist<3 && line.match(/^\t<liiiu>/)) { line = '<ul>' + line; inlist++; listtype = 'ul'; }
        lines[i] = line;
    }

    r = lines.join('\n');
	// jeff added : will correctly replace <li(o|u)> AND </li(o|u)>
    r = r.replace(/li+[o|u]>/g,'li>');

    return r;
}
