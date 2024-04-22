function hayagriva-cb
    if not command --query hayagriva
        set_color red
        echo "hayagriva (https://github.com/typst/hayagriva) not found" >&2
        set_color normal
        return 1
    end
    set -l f (mktemp --suffix=.bib)
    fish_clipboard_paste >$f
    set_color green
    echo "Formatted as Hayagriva and copied to clipboard:" >&2
    set_color normal
    hayagriva $f \
        | tail -n +2 \
        | fish_clipboard_copy
    if command --query bat
        hayagriva $f \
            | tail -n +2 \
            | bat --language yaml --paging=never
    else
        hayagriva $f | tail -n +2
    end
    rm -f $f
end
