# Reuse aliases and envs from bash config files
function _from_bash_config
	egrep "^export " $argv[1] | while read e
	    set -l var (echo $e | sed -E "s/^export ([A-Z0-9_]+)=(.*)\$/\1/")
	    set -l value (echo $e | sed -E "s/^export ([A-Z0-9_]+)=(.*)\$/\2/")
	
	    # remove surrounding quotes if existing
	    set -l value (echo $value | sed -E "s/^\"(.*)\"\$/\1/")
	
	    if test $var = "PATH"
	        # replace ":" by spaces. this is how PATH looks for Fish
	        set -l value (echo $value | sed -E "s/:/ /g")
	
	        # use eval because we need to expand the value
	        eval set -xg $var $value
	
	        continue
	    end
	
	    # evaluate variables. we can use eval because we most likely just used "$var"
	    set -l value (eval echo $value)
	
	    switch $value
	            case '`*`';
	            # executable
	            set NO_QUOTES (echo $value | sed -E "s/^\`(.*)\`\$/\1/")
	            set -x $var (eval $NO_QUOTES)
	        case '*'
	            # default
	            set -xg $var $value
	        end
	end

	if status is-interactive
		egrep "^alias " $argv[1] | while read e
		    set -l var (echo $e | sed -E "s/^alias ([A-Za-z0-9_-]+)=(.*)\$/\1/")
		    set -l value (echo $e | sed -E "s/^alias ([A-Za-z0-9_-]+)=(.*)\$/\2/")
		
		    # remove surrounding quotes if existing
		    set -l value (echo $value | sed -E "s/^\"(.*)\"\$/\1/")
		
		    # evaluate variables. we can use eval because we most likely just used "$var"
		    set -l value (eval echo $value)
		
		    # set an alias
		    alias $var="$value"
		end
	end
end

if test -e ~/.bash_profile
	_from_bash_config ~/.bash_profile
end

if test -e ~/.bashrc
	_from_bash_config ~/.bashrc
end
