function stc {
    local commandToStore
    if test "$#" -eq 0; then
        prev_cmd="$(fc -ln -2 -2 | shfmt)"
        read -e -p "Store command: " -i "$prev_cmd" commandToStore
    else
        cmd="$@"
        read -e -p "Store command: " -i "$cmd" commandToStore
    fi

    local file_name='.stored_command/default.sc.sh'
    mkdir -p .stored_command
    ls $file_name >/dev/null 2>/dev/null

    if test "$?" -ne 2; then
        local tmp_file=$(mktemp)
        ls .stored_command/*.sc.sh | cut -d/ -f2 | cut -d. -f1 >$tmp_file
        new_file_name=$(grep -E '^[a-z]{5}$' /usr/share/dict/words | grep -v -F -f $tmp_file | sort -R | head -n 1)
        file_name=".stored_command/$new_file_name.sc.sh"
    fi
    echo $commandToStore >$file_name
    echo "Command '$commandToStore' stored as $file_name"
}

function rsc {
    local cmd_count=$(ls .stored_command/*.sc.sh 2>/dev/null | wc -l)

    if [[ "$#" -eq 0 ]] && [[ -f .stored_command/default.sc.sh ]] && [[ $cmd_count -eq 1 ]]; then
        source .stored_command/default.sc.sh
    elif [[ "$#" -eq 0 ]] && [[ $cmd_count -eq 1 ]]; then
        options="$(ls .stored_command/*.sc.sh | cut -d/ -f2 | cut -d. -f1 | grep -v default)"
        readarray -t cmds <<<"$options"
        select commandToExecute in $cmds; do

            source ".stored_command/$commandToExecute.sc.sh"
            break
        done
    elif [[ "$#" -eq 0 ]] && [[ -f .stored_command/default.sc.sh ]]; then
        echo "jada jada"
        options="$(echo default $(ls .stored_command/*.sc.sh | cut -d/ -f2 | cut -d. -f1 | grep -v default))"
        echo $options
        readarray -t cmds <<<"$options"
        select commandToExecute in $cmds; do
            source ".stored_command/$commandToExecute.sc.sh"
            break
        done

    elif [[ "$#" -eq 0 ]]; then
        options="$(ls .stored_command/*.sc.sh | cut -d/ -f2 | cut -d. -f1 | grep -v default)"
        readarray -t cmds <<<"$options"
        select commandToExecute in $cmds; do
            source ".stored_command/$commandToExecute.sc.sh"
            break
        done
    elif [[ "$#" -eq 1 ]] && [[ -f ".stored_command/$1.sc.sh" ]]; then
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
