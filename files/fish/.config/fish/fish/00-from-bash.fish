# Functions
#----------
function convert-bash-to-fish
    set -l preprocessed "$(echo "$argv[1]" | while read lineorig
        set -l line "$(echo "$lineorig" | sed -E 's/[$]([^(])/$$\1/g' | sed -E 's/^\s*(.*)\s*/\1/')"
	    switch $line
	        case 'export *=*'
		        set -l var (echo $line | sed -E "s/^export ([A-Za-z0-9_-]+)=(.*)\$/\1/")
		        set -l value (echo $line | sed -E "s/^export ([A-Za-z0-9_-]+)=(.*)\$/\2/")

                set -l value (echo $value | sed -E "s/^\"(.*)\"\$/\1/")
                set -l value (echo $value | sed -E "s/^'(.*)'\$/\1/")
                set -l value (echo $value | sed -E 's/[$][$]/$/g')

	            # replace ":" by spaces. this is how PATH looks for Fish
	            if test $var = "PATH"
	                set value "$(echo $value | sed -E "s/:/\" \"/g")"
                    echo set -gx "$var" "\"$value\";"
                else
                    echo set -gx "$var" "\"$value\";"
	            end
	        case 'export *'
		        set -l var (echo $line | sed -E "s/^export ([A-Za-z0-9_-]+)\$/\1/")
                echo set -gx "$var";
	        case 'alias *=*'
		        set -l var (echo $line | sed -E "s/^alias ([A-Za-z0-9_-]+)=(.*)\$/\1/")
		        set -l value (echo $line | sed -E "s/^alias ([A-Za-z0-9_-]+)=(.*)\$/\2/")

                set -l value (echo $value | sed -E "s/^\"(.*)\"\$/\1/")
                set -l value (echo $value | sed -E "s/^'(.*)'\$/\1/")
                set -l value (echo $value | sed -E 's/[$][$]/$/g')

                echo alias "$var=\"$value\";"
	        case '*=*'
		        set -l var (echo $line | sed -E "s/^export ([A-Za-z0-9_-]+)=(.*)\$/\1/")
		        set -l value (echo $line | sed -E "s/^export ([A-Za-z0-9_-]+)=(.*)\$/\2/")

                set -l value (echo $value | sed -E "s/^\"(.*)\"\$/\1/")
                set -l value (echo $value | sed -E "s/^'(.*)'\$/\1/")
                set -l value (echo $value | sed -E 's/[$][$]/$/g')

                echo set -l "$var=\"$value\";"
	        case 'source *'
	            set -l value (echo $line | sed -E 's/^source\\s*(.*)/\1/' | sed -E "s#~#$HOME#g")

                set -l value (echo $value | sed -E "s/^\"(.*)\"\$/\1/")
                set -l value (echo $value | sed -E "s/^'(.*)'\$/\1/")
                set -l value (echo $value | sed -E 's/[$][$]/$/g')

                echo eval-bash-file "$value";
	        case 'if [[ *'
	            set -l val (echo $line | sed -E 's/^if \[\[(.*)\]\]\\s*;\\s*then\\s*/if [ \1 ]/')
	            set -l val (echo $val | sed -E 's/^if \[\[(.*)\]\]\\s*/if [ \1 ]/')
                echo "$val"
	        case 'if [ *'
	            set -l val (echo $line | sed -E 's/^if \[(.*)\]\\s*;\\s*then\\s*/if [ \1 ]/')
                echo "$val"
	        case 'if *'
	            set -l val (echo $line | sed -E 's/^if (.*)\\s*;\\s*then\\s*/if \1/')
                echo "$val"
	        case 'for *'
                set -l val (echo $line | sed -E 's/^for (.*)\\s*;\\s*do\\s*/for \1/')
                echo "$val"
	        case 'do'
                echo
	        case 'then'
                echo
	        case 'fi'
                echo end
	        case 'done'
                echo end
	        case '#*'
                echo
	        case ':'
                echo
            case ''
                echo
            case '*'
                echo "echo ERROR on line \"$line\" '(unsupported statement)' >&2"
                return 1
        end
    end)"

    echo "$preprocessed" | while read lineorig
        set -l line "$(echo "$lineorig" | sed -E 's/[$][$]/$/g')"
	    switch $line
            case '*[  -z "$PS1"  ]*'
                set -l val (echo $line | sed -E 's/\[  -z "\$PS1"  \]/status is-interactive/')
                echo "$val"
            case '*'
                echo "$line"
        end
    end
end

function convert-bash-to-fish-file
    if not set -q argv[1]
        echo "Missing file name for eval"
        return 1
    end
    convert-bash-to-fish "$(cat "$argv[1]")"
end

function eval-bash
    if not set -q argv[1]
        echo "Missing code string for eval"
        return 1
    end
    eval "$(convert-bash-to-fish "$argv[1]")"
end

function eval-bash-file
    if not set -q argv[1]
        echo "Missing file name for eval"
        return 1
    end
    eval "$(convert-bash-to-fish-file "$argv[1]")"
end


# Init
#-----
if test -e ~/.bash_profile
    eval-bash-file ~/.bash_profile
else if test -e ~/.bashrc
    eval-bash-file ~/.bashrc
end