function bib2hayagriva
    if not command --query hayagriva
        printf "%serror%s: hayagriva (https://github.com/typst/hayagriva) not found\n" (set_color red) (set_color normal) >&2
        return 1
    end

    set -l temp_bib (mktemp --suffix=.bib)
    if isatty stdin
        fish_clipboard_paste >$temp_bib
    else
        while read line
            echo $line >>$temp_bib
        end
    end

    set -l yaml (command hayagriva $temp_bib | tail -n +1)

    if isatty stdout
        printf '%s\n' $yaml | fish_clipboard_copy
        printf '%s\n' $yaml | bat --language yaml --paging=never
        # TODO: check if a references.yaml exist in the current directory (or any parent directory)
        # If it does then check if `yq` is installed, and if it is then use it to check if there is a toplevel key (the id of the reference)
        # that matches the one generated from hayagriva. If there is then append the new reference to the file, otherwise to nothing
        if test -f references.yaml
            printf '%sinfo%s: found references.yaml\n' (set_color green) (set_color normal)
            set -l temp_yaml (mktemp --suffix=.yaml)
            printf '%s\n' $yaml >$temp_yaml
            # bat $temp_yaml
            # return
            set -l new_reference (string match --regex --groups-only '^([#\S]\S+):' < $temp_yaml)
            set -l existing_references (string match --regex --groups-only '^([#\S]\S+):' < references.yaml)
            if contains -- $new_reference $existing_references
                printf '%swarn%s: %s already exists in references.yaml\n' (set_color yellow) (set_color normal) $new_reference >&2
            else
                echo "" >>references.yaml
                command cat $temp_yaml >>references.yaml
                printf '%sinfo%s: appended %s to references.yaml\n' (set_color green) (set_color normal) $new_reference >&2
            end
            command rm $temp_yaml
        end
    else
        # Write to the stdout
        printf '%s\n' $yaml
    end

    # delete temporary file
    command rm $temp_bib
end
