[[ $- != *i* ]] && return
alias g="git add . && git status -v"
alias b="git branch"
alias gg="git add . && git status -v | riff"
alias gm="git checkout master"
alias gmhr="git fetch upstream master && git reset --hard upstream/master"
alias gdhr="git fetch upstream develop-live && git reset --hard upstream/develop-live"
alias sghr="git read-tree --reset -u upstream/master"
alias gmr="git fetch upstream master && git merge upstream/master --no-edit"
alias gmc="git merge --continue"
alias grc="git rebase --continue"
alias gr="git rebase -i HEAD~2"
alias gs="git status"
alias gca="git commit --amend"
alias gcae="git commit --amend --no-edit"
alias bd="git branch | rg -v 'master' | xargs git branch -D"
alias up="git pull upstream master --rebase"
alias gc="git clone"
alias gs="git status"
alias gcm="git commit -m"
alias dm="git diff upstream/master..HEAD | riff"
alias ddv="git diff upstream/develop-live..HEAD | riff"
alias dt="riff /tmp/k0 /tmp/k1"
alias iso="printf '%s ' \"\$(date +'%Y-%m-%dT%H:%M:%S%z' | sed -E 's/([0-9]{2})([0-9]{2})$/\1:\2/')\" | pbcopy"
function gd() {
  eval $(open https://github.com/$(git remote get-url upstream | cut -d':' -f2)/compare/master...qazalin:$(git branch --show-current))
}

function gco() {
    if [ $# -eq 0 ]; then
        echo "Usage: gc 'your message'"
        return 1
    fi
    git add -A && git commit -m "$*"
}

function nuke() {
    if [ $# -eq 0 ]; then
        echo "Usage: nuke <commit/ref>   (e.g. HEAD~2, abc1234)"
        return 1
    fi
    git reset --hard "$1"
}

# Create PR quickly (assumes branch already pushed)
# Usage: gpr master    or   gpr develop "Better title than branch name"
function gpr() {
    local base="master"
    local title=""

    if [ $# -ge 1 ]; then
        base="$1"
        shift
    fi

    if [ $# -gt 0 ]; then
        title="$*"
    else
        title="$(git rev-parse --abbrev-ref HEAD)"
    fi

    gh pr create \
        --base "$base" \
        --title "$title" \
        --draft \
        --web
}

# Open current PR in browser (to check /files tab)
function prv() {
    gh pr view --web
}

PS1='$(if [[ $? == 0 ]]; then echo "\w"; else echo "\[\e[31m\]\w\[\e[0m\]"; fi)$(git branch 2>/dev/null | grep \* | sed "s/* / (/" | sed "s/$/) /")> '

export TERM=tmux-256color
export COLORTERM=truecolor
stty -ixon
bind -x '"\C-s": "~/tmux-sessionizer.sh"'
bind -x '"\C-f": "~/tmux-sessionfinder.sh"'
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend
PROMPT_COMMAND='history -a; history -n; '"$PROMPT_COMMAND"
PATH="/opt/homebrew/opt/python@3.12/libexec/bin:$HOME/bin:/usr/local/bin:/opt/homebrew/bin:/usr/local/sbin:$HOME/.cargo/bin:/sbin:/opt/homebrew/opt/llvm@21/bin:/usr/lib/llvm/bin/:$HOME/.fzf/bin:$HOME/code/kernel/bin:/opt/homebrew/opt/gnu-sed/libexec/gnubin:$HOME/.local/bin:$PATH"

export BASH_SILENCE_DEPRECATION_WARNING=1

fzf_search_history() {
  local found
  found=$(cat $HISTFILE | awk '{sub(/^[[:space:]]*[0-9]+[[:space:]]*/,""); gsub(/^[[:space:]]+|[[:space:]]+$/,""); gsub(/[[:space:]]+/," "); lines[++n]=$0} END {for(i=n;i>=1;i--) if(!seen[lines[i]]++) print lines[i]}' | fzf -e +s --height 20%)
  if [[ -n $found ]]; then
    READLINE_LINE=$found
    READLINE_POINT=0x7fffffff
  fi
}
bind -x '"\C-r": fzf_search_history'
bind -m vi-command -x '"\C-r": fzf_search_history'
bind -m vi-insert -x '"\C-r": fzf_search_history'

export PATH="$HOME/.config/emacs/bin:$PATH"
export PATH="$HOME/flutter/bin:$PATH"

export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include"

test -s ~/.alias && . ~/.alias || true

function grf() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: git-reset-force <commit-hash> <branch-name>"
        return 1
    fi
    read -p "Are you sure you want to hard reset and force push to branch '$2'? This is destructive. (y/N): " confirm
    if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
        echo "Proceeding with git reset --hard $1 && git push origin $2 --force"
        git reset --hard "$1" && git push origin "$2" --force
    else
        echo "Operation cancelled."
    fi
}

# ==================== yt-dlp Advanced Shortcuts ====================
yt() {
    local opt="$1"
    local url="$2"

    case "$opt" in
        # === Quality Options ===
        2160|4k|4K)
            echo "📥 Downloading best 4K (2160p)..."
            yt-dlp -S "res:2160" --merge-output-format mp4 --embed-subs --embed-metadata "$url"
            ;;
        
        1440|2k|2K)
            echo "📥 Downloading best 1440p (2K)..."
            yt-dlp -S "res:1440" --merge-output-format mp4 --embed-subs --embed-metadata "$url"
            ;;
            
        1080)
            echo "📥 Downloading best 1080p..."
            yt-dlp -S "res:1080" --merge-output-format mp4 --embed-subs --embed-metadata "$url"
            ;;
            
        720)
            echo "📥 Downloading best 720p..."
            yt-dlp -S "res:720" --merge-output-format mp4 --embed-subs --embed-metadata "$url"
            ;;
            
        480)
            echo "📥 Downloading best 480p..."
            yt-dlp -S "res:480" --merge-output-format mp4 --embed-subs --embed-metadata "$url"
            ;;
            
        360)
            echo "📥 Downloading best 360p..."
            yt-dlp -S "res:360" --merge-output-format mp4 --embed-subs --embed-metadata "$url"
            ;;
            
        240)
            echo "📥 Downloading best 240p..."
            yt-dlp -S "res:240" --merge-output-format mp4 --embed-subs --embed-metadata "$url"
            ;;

        # === Special Options ===
        best|highest)
            echo "📥 Downloading highest available quality..."
            yt-dlp -S "res,best" --merge-output-format mp4 --embed-subs --embed-metadata "$url"
            ;;
            
        q|Q|list|formats|f)
            echo "🔍 Listing available formats..."
            yt-dlp -F "$url" | tail -n 40
            ;;
            
        audio|mp3|a)
            echo "🎵 Downloading audio only (best quality mp3)..."
            yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-metadata "$url"
            ;;
            
        opus|webm)
            echo "🎵 Downloading best audio (opus)..."
            yt-dlp -x --audio-format opus --embed-metadata "$url"
            ;;
            
        thumb|thumbnail)
            echo "🖼️  Downloading thumbnail..."
            yt-dlp --write-thumbnail --skip-download "$url"
            ;;
            
        *)
            echo "📋 Usage:"
            echo "   yt 4k      <URL>     → 2160p (4K)"
            echo "   yt 1440    <URL>     → 1440p (2K)"
            echo "   yt 1080    <URL>     → 1080p"
            echo "   yt 720     <URL>     → 720p"
            echo "   yt 480     <URL>     → 480p"
            echo "   yt 360     <URL>     → 360p"
            echo "   yt 240     <URL>     → 240p"
            echo ""
            echo "   yt best    <URL>     → Best available"
            echo "   yt q       <URL>     → List all formats"
            echo "   yt audio   <URL>     → MP3 audio only"
            echo "   yt thumb   <URL>     → Download thumbnail only"
            echo ""
            echo "Example: yt 720 https://youtu.be/xxxx"
            ;;
    esac
}


alias c="clear"
alias q="exit"
alias v="vim"
alias r="rmdir"
alias t="tmux"
alias o="cat"
alias xx="sudo shutdown now"
alias hh="sudo systemctl hibernate"
alias p="python3"
. "$HOME/.cargo/env"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# pnpm
export PNPM_HOME="/home/blackginger/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


