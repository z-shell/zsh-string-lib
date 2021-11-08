# -*- mode: sh; sh-indentation: 4; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# According to the Zsh Plugin Standard:
# http://z-shell.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

if [[ ${zsh_loaded_plugins[-1]} != */zsh-string-lib && -z ${fpath[(r)${0:h}]} ]]
then
    fpath+=( "${0:h}" )
fi

zmodload zsh/system 2>/dev/null

autoload -Uz \
    @str-parse-json \
    @str-read-all \
    @str-ng-match \
    @str-ng-matches \
    @str-read-ini \
    @str-read-toml \
    @str-dump
