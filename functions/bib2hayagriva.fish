function bib2hayagriva
    if not command --query hayagriva
        printf "%serror%s: hayagriva (https://github.com/typst/hayagriva) not found" (set_color red) (set_color normal) >&2
        return 1
    end

    set -l f (mktemp --suffix=.bib)
    if isatty stdin
        fish_clipboard_paste >$f
    else
        while read line
            echo $line >>$f
        end
    end

    if isatty stdout
        #
        command hayagriva $f | tail -n +1 | fish_clipboard_copy
        command hayagriva $f | tail -n +1 | bat --language yaml --paging=never
        # TODO: check if a references.yaml exist in the current directory (or any parent directory)
        # If it does then check if `yq` is installed, and if it is then use it to check if there is a toplevel key (the id of the reference)
        # that matches the one generated from hayagriva. If there is then append the new reference to the file, otherwise to nothing
    else
        # Write to the output stream
        command hayagriva $f
        # command cat $f
    end

    command rm $f
end
