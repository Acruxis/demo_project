#!/bin/bash
# paste_local_config.sh — 将 $HOME 的 dotfiles 打包进仓库
# 与 paste_config.sh 互为反向
# 用法: ./paste_local_config.sh [target]
# target: all(默认) | bash | zsh | tmux | vim | git
set -e

usage() {
    echo "用法: $0 [target]"
    echo "target: all(默认) | bash | zsh | tmux | vim | git"
    exit 0
}

TARGET="${1:-all}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
H="$HOME"

pack_bash() {
    echo "[bash] ~/.bash_aliases → bash/bash_aliases"
    cp -f "$H/.bash_aliases" "$SCRIPT_DIR/bash/bash_aliases"
}

pack_zsh() {
    echo "[zsh] 打包 .oh-my-zsh .zshrc .zsh_aliases .p10k.zsh (排除 cache)"
    tar cf "$SCRIPT_DIR/zsh/zsh_dotfile.tar" \
        -C "$H" \
        --exclude-vcs \
        --exclude='.oh-my-zsh/cache/*' \
        .oh-my-zsh .zshrc .zsh_aliases .p10k.zsh 2>/dev/null || {
        tar cf "$SCRIPT_DIR/zsh/zsh_dotfile.tar" \
            -C "$H" \
            --exclude='*.git*' \
            --exclude='.oh-my-zsh/cache/*' \
            .oh-my-zsh .zshrc .zsh_aliases .p10k.zsh
    }
}

pack_tmux() {
    echo "[tmux] 打包 .tmux/ (排除 .git)"
    cp -f "$H/.tmux/tmux.conf" "$SCRIPT_DIR/tmux/tmux.conf"
    tar cf "$SCRIPT_DIR/tmux/tmux_conf.tar" \
        -C "$H" \
        --exclude-vcs \
        .tmux 2>/dev/null || {
        tar cf "$SCRIPT_DIR/tmux/tmux_conf.tar" \
            -C "$H" \
            --exclude='*.git*' \
            .tmux
    }
}

pack_vim() {
    echo "[vim] 打包 .vim .vim_runtime .vimrc"
    cp -f "$H/.vimrc" "$SCRIPT_DIR/vim/vimrc"
    tar cf "$SCRIPT_DIR/vim/vim_conf.tar" \
        -C "$H" \
        --exclude-vcs \
        .vim .vim_runtime .vimrc 2>/dev/null || {
        tar cf "$SCRIPT_DIR/vim/vim_conf.tar" \
            -C "$H" \
            --exclude='*.git*' \
            .vim .vim_runtime .vimrc
    }
}

pack_git() {
    echo "[git] ~/.gitconfig → git/git.config"
    cp -f "$H/.gitconfig" "$SCRIPT_DIR/git/git.config"
}

case "$TARGET" in
    all)   pack_bash; pack_zsh; pack_tmux; pack_vim; pack_git ;;
    bash)  pack_bash ;;
    zsh)   pack_zsh ;;
    tmux)  pack_tmux ;;
    vim)   pack_vim ;;
    git)   pack_git ;;
    -h|--help) usage ;;
    *)     echo "未知 target: $TARGET"; usage ;;
esac

echo ""
echo "=== 打包完成 ==="
