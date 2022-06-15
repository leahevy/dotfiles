if status is-interactive
	if command -v git &> /dev/null
		set ORIG_GIT /usr/bin/git
	    function git
	        if not set -q argv[1]
	            $ORIG_GIT st
	        else
	            $ORIG_GIT $argv
	        end
	    end
		alias g="git"
	end
end
