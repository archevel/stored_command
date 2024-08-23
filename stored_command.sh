function stc {
    local commandToStore
    if test "$#" -eq 0; then
        prev_cmd="$(fc -ln -2 -2 | shfmt)"
        read -e -p "Store command: " -i "$prev_cmd" commandToStore
    else
        cmd="$@"
        read -e -p "Store command: " -i "$cmd" commandToStore
    fi

    local commandName='default'
    local file_name=".stored_command/$commandName.sc.sh"
    mkdir -p .stored_command
    ls $file_name >/dev/null 2>/dev/null

    if test "$?" -ne 2; then
        local tmp_file=$(mktemp)
        ls .stored_command/*.sc.sh | cut -d/ -f2 | cut -d. -f1 >$tmp_file
        commandName=$(grep -E '^[a-z]{5}$' /usr/share/dict/words | grep -v -F -f $tmp_file | sort -R | head -n 1)
    fi
    if [[ -f "$tmp_file" ]]; then
        echo Commands stored:
        cat $tmp_file
    fi
    read -e -p "Store command as: " -i "$commandName" commandName
    file_name=".stored_command/$commandName.sc.sh"
    echo $commandToStore >$file_name
    echo "Command '$commandToStore' stored as $file_name"
}

function rsc {
    local cmd_count=$(ls .stored_command/*.sc.sh 2>/dev/null | wc -l)

    if [[ "$#" -eq 0 ]] && [[ -f .stored_command/default.sc.sh ]] && [[ $cmd_count -eq 1 ]]; then
        read -e -p "Execute default command? " -i y execute
        if [[ "${execute,,}" = "y" ]] || [[ "${execute,,}" = "yes" ]]; then
            cat ".stored_command/default.sc.sh"
            source .stored_command/default.sc.sh
        fi
    elif [[ "$#" -eq 0 ]] && [[ $cmd_count -eq 1 ]]; then
        options="$(ls .stored_command/*.sc.sh | cut -d/ -f2 | cut -d. -f1 | grep -v default)"
        readarray -t cmds <<<"$options"
        select commandToExecute in $cmds; do
            echo "Executing $commandToExecute:"
            cat ".stored_command/$commandToExecute.sc.sh"
            source ".stored_command/$commandToExecute.sc.sh"
            break
        done
    elif [[ "$#" -eq 0 ]] && [[ -f .stored_command/default.sc.sh ]]; then
        options="$(echo default $(ls .stored_command/*.sc.sh | cut -d/ -f2 | cut -d. -f1 | grep -v default))"
        echo $options
        readarray -t cmds <<<"$options"
        select commandToExecute in $cmds; do
            echo "Executing $commandToExecute:"
            cat ".stored_command/$commandToExecute.sc.sh"
            source ".stored_command/$commandToExecute.sc.sh"
            break
        done

    elif [[ "$#" -eq 0 ]]; then
        options="$(ls .stored_command/*.sc.sh | cut -d/ -f2 | cut -d. -f1 | grep -v default)"
        readarray -t cmds <<<"$options"
        select commandToExecute in $cmds; do
            echo "Executing $commandToExecute:"
            cat ".stored_command/$commandToExecute.sc.sh"
            source ".stored_command/$commandToExecute.sc.sh"
            break
        done
    elif [[ "$#" -eq 1 ]] && [[ -f ".stored_command/$1.sc.sh" ]]; then
        echo "Executing $1:"
        cat ".stored_command/$1.sc.sh"
        source ".stored_command/$1.sc.sh"
    else
        echo "Command '$@' not found"
    fi
}

function lsc {
    local cmd_count=$(ls .stored_command/*.sc.sh 2>/dev/null | wc -l)
    if [[ $cmd_count -eq 0 ]]; then
        echo "No stored commands found"
    else
        ls .stored_command/*.sc.sh | cut -d/ -f2 | cut -d. -f1
    fi
}
