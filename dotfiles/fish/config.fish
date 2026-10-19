if status is-interactive
    # branded system readout on terminal open.
    if command -v fastfetch >/dev/null 2>&1
        fastfetch
    end

    # prompt.
    if command -v starship >/dev/null 2>&1
        starship init fish | source
    end

    # directory jumper: hook `cd` into zoxide so plain `cd` learns and jumps to
    # frecent dirs (`cdi` for an interactive pick).
    if command -v zoxide >/dev/null 2>&1
        zoxide init fish | source
    end

    # runtime version manager: shims + per-project tool versions.
    if command -v mise >/dev/null 2>&1
        mise activate fish | source
    end

    # fzf walks the tree via fd when present.
    if command -v fd >/dev/null 2>&1
        set -gx FZF_DEFAULT_COMMAND 'fd --hidden --follow --exclude .git'
        set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
        set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
    end

    # fzf keys: Ctrl-R history, Ctrl-T files, Alt-C cd.
    if command -v fzf >/dev/null 2>&1
        fzf --fish | source
    end

    # eza listings.
    if command -v eza >/dev/null 2>&1
        alias ls 'eza -lh --group-directories-first --icons=auto'
        alias lsa 'ls -a'
        alias lt 'eza --tree --level=2 --long --icons --git'
        alias lta 'lt -a'
    end
end

test -f $__fish_config_dir/user.fish && source $__fish_config_dir/user.fish

if status is-login
    set -Ux XMODIFIERS @im=fcitx
    set -Ux QT_IM_MODULE fcitx
    set -Ux QT_IM_MODULES "wayland;fcitx"
end
