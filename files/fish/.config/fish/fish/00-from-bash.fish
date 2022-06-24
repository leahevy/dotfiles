# Functions
#----------
function convert-bash-to-fish
    if [ -e "$HOMEBREW_PATH/gsed" ]
        set _SED_CMD "$HOMEBREW_PATH/gsed"
    else
        set _SED_CMD "/usr/bin/sed"
    end

    set -l preprocessed "$(echo "$argv[1]" | while read lineorig
        set -l line "$(echo "$lineorig" | $_SED_CMD -E 's/[$]([^(])/$$\1/g' | $_SED_CMD -E 's/^\s*(.*)\s*/\1/')"
	    switch $line
	        case 'export *=*'
		        set -l var (echo $line | $_SED_CMD -E "s/^export ([A-Za-z0-9_-]+)=(.*)\$/\1/")
		        set -l value (echo $line | $_SED_CMD -E "s/^export ([A-Za-z0-9_-]+)=(.*)\$/\2/")

                set -l value (echo $value | $_SED_CMD -E "s/^\"(.*)\"\$/\1/")
                set -l value (echo $value | $_SED_CMD -E "s/^'(.*)'\$/\1/")
                set -l value (echo $value | $_SED_CMD -E 's/[$][$]/$/g')

	            # replace ":" by spaces. this is how PATH looks for Fish
	            if test $var = "PATH"
	                set value "$(echo $value | $_SED_CMD -E "s/:/\" \"/g")"
                    echo set -gx "$var" "\"$value\";"
                else
                    echo set -gx "$var" "\"$value\";"
	            end
	        case 'export *'
		        set -l var (echo $line | $_SED_CMD -E "s/^export ([A-Za-z0-9_-]+)\$/\1/")
                echo set -gx "$var";
	        case 'alias *=*'
		        set -l var (echo $line | $_SED_CMD -E "s/^alias ([A-Za-z0-9_-]+)=(.*)\$/\1/")
		        set -l value (echo $line | $_SED_CMD -E "s/^alias ([A-Za-z0-9_-]+)=(.*)\$/\2/")

                set -l value (echo $value | $_SED_CMD -E "s/^\"(.*)\"\$/\1/")
                set -l value (echo $value | $_SED_CMD -E "s/^'(.*)'\$/\1/")
                set -l value (echo $value | $_SED_CMD -E 's/[$][$]/$/g')

                echo alias "$var='$value';"
	        case 'source *'
	            set -l value (echo $line | $_SED_CMD -E 's/^source\\s*(.*)/\1/' | $_SED_CMD -E "s#~#$HOME#g")

                set -l value (echo $value | $_SED_CMD -E "s/^\"(.*)\"\$/\1/")
                set -l value (echo $value | $_SED_CMD -E "s/^'(.*)'\$/\1/")
                set -l value (echo $value | $_SED_CMD -E 's/[$][$]/$/g')

                echo eval-bash-file "$value";
	        case '*if [[ *'
	            set -l val (echo $line | $_SED_CMD -E 's/^(.*)if \[\[(.*)\]\]\\s*;\\s*then\\s*/\1if [ \2 ]/')
	            set -l val (echo $val | $_SED_CMD -E 's/^(.*)if \[\[(.*)\]\]\\s*/if [ \1 ]/')
                echo "$val"
	        case '*if [ *'
	            set -l val (echo $line | $_SED_CMD -E 's/^(.*)if \[(.*)\]\\s*;\\s*then\\s*/\1if [ \2 ]/')
                echo "$val"
	        case '*if *'
	            set -l val (echo $line | $_SED_CMD -E 's/^(.*)if (.*)\\s*;\\s*then\\s*/\1if \2/')
                echo "$val"
	        case '*()*{'
                set -l val (echo $line | $_SED_CMD -E 's/^(.*)\(\)\\s*\{\\s*/function \1/')
                echo "$val"
	        case '}'
                echo end
	        case 'for *'
                set -l val (echo $line | $_SED_CMD -E 's/^for (.*)\\s*;\\s*do\\s*/for \1/')
                echo "$val"
	        case '*=*'
		        set -l var (echo $line | $_SED_CMD -E "s/^([A-Za-z0-9_-]+)=(.*)\$/\1/")
		        set -l value (echo $line | $_SED_CMD -E "s/^([A-Za-z0-9_-]+)=(.*)\$/\2/")

                set -l value (echo $value | $_SED_CMD -E "s/^\"(.*)\"\$/\1/")
                set -l value (echo $value | $_SED_CMD -E "s/^'(.*)'\$/\1/")
                set -l value (echo $value | $_SED_CMD -E 's/[$][$]/$/g')

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
        set -l line "$(echo "$lineorig" | $_SED_CMD -E 's/[$][$]/$/g')"

        set line "$(echo $line | $_SED_CMD -E 's/\[  ! -z "\$PS1"  \]/status --is-interactive/')"

        set line "$(echo $line | $_SED_CMD -E 's/"\$@"/$argv/')"

        set line "$(echo $line | $_SED_CMD -E 's/\$0/$(status filename)/')"

        set line "$(echo $line | $_SED_CMD -E 's/\$1/$argv[1]/')"
        set line "$(echo $line | $_SED_CMD -E 's/\$2/$argv[2]/')"
        set line "$(echo $line | $_SED_CMD -E 's/\$3/$argv[3]/')"
        set line "$(echo $line | $_SED_CMD -E 's/\$4/$argv[4]/')"
        set line "$(echo $line | $_SED_CMD -E 's/\$5/$argv[5]/')"
        set line "$(echo $line | $_SED_CMD -E 's/\$6/$argv[6]/')"
        set line "$(echo $line | $_SED_CMD -E 's/\$7/$argv[7]/')"
        set line "$(echo $line | $_SED_CMD -E 's/\$8/$argv[8]/')"
        set line "$(echo $line | $_SED_CMD -E 's/\$9/$argv[9]/')"

        echo "$line"
    end
end

function convert-bash-to-fish-file
    if not set -q argv[1]
        echo "Missing file name for eval"
        return 1
    end
    set -l RECREATE "false"
    # Cached result exists
    if [ -e "/tmp/fishcache/$argv[1]" ]
        # Check if source file has changed
        if [ "$(md5sum "$argv[1]" | cut -f1 -d " ")" != "$(cat "/tmp/fishcache/$argv[1]._STAT")" ]
            set RECREATE "true"
        end
    else
        set RECREATE "true"
    end
    if [ "$RECREATE" = "true" ]
        mkdir -p "$(dirname "/tmp/fishcache/$argv[1]")" >/dev/null
        md5sum "$argv[1]" | cut -f1 -d " " > "/tmp/fishcache/$argv[1]._STAT"
        convert-bash-to-fish "$(cat "$argv[1]")" > "/tmp/fishcache/$argv[1]"
    end
    cat "/tmp/fishcache/$argv[1]"
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