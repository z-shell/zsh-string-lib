# According to the Zsh Plugin Standard:
# https://github.com/z-shell/zi/wiki/Zsh-Plugin-Standard
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

if [[ $PMSPEC != *f* ]] {
  fpath+=( "${0:h}/functions" )
} 

zmodload zsh/system 2>/dev/null

autoload -Uz \
    @str-parse-json \
    @str-read-all \
    @str-ng-match \
    @str-ng-matches \
    @str-read-ini \
    @str-read-toml \
    @str-dump
