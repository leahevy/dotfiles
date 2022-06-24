# Functions
#----------
function convert-bash-to-fish
    set -l SED "/usr/bin/sed"

    set -l preprocessed "$(echo "$argv[1]" | while read lineorig
        set -l line "$(echo "$lineorig" | $SED -E 's/[$]([^(])/$$\1/g' | sed -E 's/^\s*(.*)\s*/\1/')"
	    switch $line
	        case 'export *=*'
		        set -l var (echo $line | $SED -E "s/^export ([A-Za-z0-9_-]+)=(.*)\$/\1/")
		        set -l value (echo $line | $SED -E "s/^export ([A-Za-z0-9_-]+)=(.*)\$/\2/")

                set -l value (echo $value | $SED -E "s/^\"(.*)\"\$/\1/")
                set -l value (echo $value | $SED -E "s/^'(.*)'\$/\1/")
                set -l value (echo $value | $SED -E 's/[$][$]/$/g')

	            # replace ":" by spaces. this is how PATH looks for Fish
	            if test $var = "PATH"
	                set value "$(echo $value | $SED -E "s/:/\" \"/g")"
                    echo set -gx "$var" "\"$value\";"
                else
                    echo set -gx "$var" "\"$value\";"
	            end
	        case 'export *'
		        set -l var (echo $line | $SED -E "s/^export ([A-Za-z0-9_-]+)\$/\1/")
                echo set -gx "$var";
	        case 'alias *=*'
		        set -l var (echo $line | $SED -E "s/^alias ([A-Za-z0-9_-]+)=(.*)\$/\1/")
		        set -l value (echo $line | $SED -E "s/^alias ([A-Za-z0-9_-]+)=(.*)\$/\2/")

                set -l value (echo $value | $SED -E "s/^\"(.*)\"\$/\1/")
                set -l value (echo $value | $SED -E "s/^'(.*)'\$/\1/")
                set -l value (echo $value | $SED -E 's/[$][$]/$/g')

                echo alias "$var='$value';"
	        case 'source *'
	            set -l value (echo $line | $SED -E 's/^source\\s*(.*)/\1/' | sed -E "s#~#$HOME#g")

                set -l value (echo $value | $SED -E "s/^\"(.*)\"\$/\1/")
                set -l value (echo $value | $SED -E "s/^'(.*)'\$/\1/")
                set -l value (echo $value | $SED -E 's/[$][$]/$/g')

                echo eval-bash-file "$value";
	        case 'if [[ *'
	            set -l val (echo $line | $SED -E 's/^if \[\[(.*)\]\]\\s*;\\s*then\\s*/if [ \1 ]/')
	            set -l val (echo $val | $SED -E 's/^if \[\[(.*)\]\]\\s*/if [ \1 ]/')
                echo "$val"
	        case 'if [ *'
	            set -l val (echo $line | $SED -E 's/^if \[(.*)\]\\s*;\\s*then\\s*/if [ \1 ]/')
                echo "$val"
	        case 'if *'
	            set -l val (echo $line | $SED -E 's/^if (.*)\\s*;\\s*then\\s*/if \1/')
                echo "$val"
	        case '*()*{'
                set -l val (echo $line | $SED -E 's/^(.*)\(\)\\s*\{\\s*/function \1/')
                echo "$val"
	        case '}'
                echo end
	        case 'for *'
                set -l val (echo $line | $SED -E 's/^for (.*)\\s*;\\s*do\\s*/for \1/')
                echo "$val"
	        case '*=*'
		        set -l var (echo $line | $SED -E "s/^([A-Za-z0-9_-]+)=(.*)\$/\1/")
		        set -l value (echo $line | $SED -E "s/^([A-Za-z0-9_-]+)=(.*)\$/\2/")

                set -l value (echo $value | $SED -E "s/^\"(.*)\"\$/\1/")
                set -l value (echo $value | $SED -E "s/^'(.*)'\$/\1/")
                set -l value (echo $value | $SED -E 's/[$][$]/$/g')

                echo set "$var \"$value\";"
	        case 'do'
                echo
	        case 'then'
                echo
	        case 'fi'
                echo end
	        case 'done'
                echo end
	        case 'else'
                echo else
	        case '#*'
                echo
	        case ':'
                echo
            case ''
                echo
            case '*'
                echo "$line"
        end
    end 2>&1)"

    echo "$preprocessed" | while read lineorig
        set -l line "$(echo "$lineorig" | $SED -E 's/[$][$]/$/g')"

        set line "$(echo $line | $SED -E 's/\[  ! -z "\$PS1"  \]/status --is-interactive/')"

        set line "$(echo $line | $SED -E 's/"\$@"/$argv/')"

        set line "$(echo $line | $SED -E 's/\$0/$(status filename)/')"

        set line "$(echo $line | $SED -E 's/\$1/$argv[1]/')"
        set line "$(echo $line | $SED -E 's/\$2/$argv[2]/')"
        set line "$(echo $line | $SED -E 's/\$3/$argv[3]/')"
        set line "$(echo $line | $SED -E 's/\$4/$argv[4]/')"
        set line "$(echo $line | $SED -E 's/\$5/$argv[5]/')"
        set line "$(echo $line | $SED -E 's/\$6/$argv[6]/')"
        set line "$(echo $line | $SED -E 's/\$7/$argv[7]/')"
        set line "$(echo $line | $SED -E 's/\$8/$argv[8]/')"
        set line "$(echo $line | $SED -E 's/\$9/$argv[9]/')"

        echo "$line"
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