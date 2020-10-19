# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export ZSH="/home/simon/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"
#ZSH_THEME="agnoster"

source $ZSH/oh-my-zsh.sh

source <(antibody init)
antibody bundle < ~/.zsh_plugins.txt

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# autocompletion
fpath=(~/.zsh/completion $fpath)
autoload -Uz compinit && compinit -i

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

complete -C '/usr/bin/aws_completer' aws

source "$HOME/.sdkman/bin/sdkman-init.sh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh