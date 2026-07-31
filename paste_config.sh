#!/bin/bash
# paste_config.sh — 将仓库中的 dotfiles 部署到 $HOME
# 用法: ./paste_config.sh [target]
# target: all(默认) | bash | zsh | tmux | vim | git
set -e

usage() {
    echo "用法: $0 [target]"
    echo "target: all(默认) | bash | zsh | tmux | vim | git"
    exit 0
}

TARGET="${1:-all}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

deploy_bash() {
    echo "[bash] bash_aliases → ~/.bash_aliases"
    cp -rf "$SCRIPT_DIR/bash/bash_aliases" ~/.bash_aliases
}

deploy_zsh() {
    if command -v zsh >/dev/null 2>&1; then
        echo "[zsh] 解压 zsh_dotfile.tar → ~/"
        tar xf "$SCRIPT_DIR/zsh/zsh_dotfile.tar" -C ~/
    else
        echo "[zsh] 跳过 (zsh 未安装)"
    fi
}

deploy_tmux() {
    if command -v tmux >/dev/null 2>&1; then
        echo "[tmux] 解压 tmux_conf.tar → ~/"
        tar xf "$SCRIPT_DIR/tmux/tmux_conf.tar" -C ~/
        ln -sf "$HOME/.tmux/tmux.conf" "$HOME/.tmux.conf"
    else
        echo "[tmux] 仅复制 standalone tmux.conf"
        cp -rf "$SCRIPT_DIR/tmux/tmux.conf" ~/.tmux.conf
    fi
}

deploy_vim() {
    echo "[vim] 解压 vim_conf.tar → ~/"
    tar xf "$SCRIPT_DIR/vim/vim_conf.tar" -C ~/
}

deploy_git() {
    echo "[git] git.config → ~/.gitconfig"
    cp -rf "$SCRIPT_DIR/git/git.config" ~/.gitconfig
}

case "$TARGET" in
    all)   deploy_bash; deploy_zsh; deploy_tmux; deploy_vim; deploy_git ;;
    bash)  deploy_bash ;;
    zsh)   deploy_zsh ;;
    tmux)  deploy_tmux ;;
    vim)   deploy_vim ;;
    git)   deploy_git ;;
    -h|--help) usage ;;
    *)     echo "未知 target: $TARGET"; usage ;;
esac

echo "完成。"
