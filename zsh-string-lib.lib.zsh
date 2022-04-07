# Standardized $0 Handling
# https://z.digitalclouds.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# Functions directory
# https://z.digitalclouds.dev/community/zsh_plugin_standard#funtions-directory
if [[ $PMSPEC != *f* ]] {
    fpath+=( "${0:h}/functions" )
}

zmodload zsh/system 2>/dev/null

# API-like functions
# https://z.digitalclouds.dev/community/zsh_plugin_standard#the-proposed-function-name-prefixes
autoload -Uz \
    @str-parse-json \
    @str-read-all \
    @str-ng-match \
    @str-ng-matches \
    @str-read-ini \
    @str-read-toml \
    @str-dump
