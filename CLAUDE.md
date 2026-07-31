# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概述

这是一个双重用途的仓库：既包含 WSL2/Ubuntu 环境下的个人 dotfiles/配置文件集合，也是一个 C++ 多线程演示项目。C++ 相关文件集中在 `cpp_demo/` 子目录，dotfiles 配置仍分布在根目录各子目录（`bash/`、`zsh/`、`tmux/` 等）。

## 构建与运行

### 主要构建方式：`cpp_demo/make_code`

这是 CMake 项目的标准构建脚本。**默认行为是仅编译**（等同于 `-c`），需要显式指定 `-r` 才会重建。所有 C++ 构建命令均需先在 `cpp_demo/` 目录下执行（`cd cpp_demo`）。

Debug/Release 使用不同的构建目录（`build/debug` / `build/release`），互不干扰。

| 选项 | 说明 |
|------|------|
| `-d` / `--debug` | Debug 模式构建（默认 Release，对应 `build/debug` 目录） |
| `-u` / `--unit-test` | 启用单元测试（`-DUNIT_TEST=ON`） |
| `-r` / `--rebuild` | 删除构建目录后重新 cmake 配置 + 编译 |
| `-B <dir>` / `--build-dir=<dir>` | 手动指定构建目录（覆盖自动推导的 `build/release` 或 `build/debug`） |
| `-S <dir>` / `--source-dir=<dir>` | 指定源码目录（默认 `.`） |
| `-P <n>` / `--parallel=<n>` | 并行编译数（默认 10） |
| `-T <tgt>` / `--target=<tgt>` | 指定 CMake target（默认 `all`） |
| `-c` / `--compile` | 仅编译（默认行为，保留此选项用于向后兼容） |
| `-h` / `--help` | 显示帮助 |

**常用示例：**
```bash
./make_code              # 仅编译 Release（build/release/）
./make_code -d           # 仅编译 Debug（build/debug/）
./make_code -r           # 重建 Release
./make_code -r -d        # 重建 Debug
./make_code -B out -P 4  # 自定义构建目录和并行数
```

### 快速单文件编译：`cpp_demo/quick_make_code/`

用于快速编译单个 `.cpp` 文件，无需 CMake。分两步：

```bash
# 第一步：编译 mk 工具（只需执行一次）
g++ cpp_demo/quick_make_code/make_code.cpp -o mk -std=c++11

# 第二步：用 mk 编译任意 cpp 文件（在 cpp_demo/ 下）
./mk main.cpp     # 输出到 ./test
./mk foo.cpp      # 输出到 ./test
```

`.gitignore` 中已忽略 `mk` 和 `test` 这两个构建产物。

### Bash 别名（来自 `bash/bash_aliases`，通过 `paste_config.sh` 部署）

- `bld` — cmake 配置 + 编译（`cmake -B build && cmake --build build --parallel=10`）
- `cpl` — 仅编译（`cmake --build build --parallel=10`）
- `rebld` — 清理 + 配置 + 编译
- `git_AM` — `git add . -A && git commit -m` 快捷方式
- `vpn_port` / `unvpn_port` — 开启/关闭 `http_proxy`/`https_proxy` 代理

## 环境部署

### 部署 dotfiles：`paste_config.sh` / `paste_local_config.sh`

`paste_config.sh` 把仓库配置部署到 `$HOME`；`paste_local_config.sh` 与之反向，把 `$HOME` 的配置打包回仓库（更新后需重新提交 tar 包）。两者都接受 `[target]` 参数：`all`(默认) | `bash` | `zsh` | `tmux` | `vim` | `git`。

**部署规则（`paste_config.sh`）：**
- `bash/bash_aliases` → `~/.bash_aliases`
- `git/git.config` → `~/.gitconfig`
- `zsh/zsh_dotfile.tar` → 解压到 `~/`（仅当 zsh 可用时）
- `tmux/tmux_conf.tar` → 解压到 `~/`，并 `ln -sf ~/.tmux/tmux.conf ~/.tmux.conf`（仅当 tmux 可用时）；否则仅复制独立的 `tmux/tmux.conf` → `~/.tmux.conf`
- `vim/vim_conf.tar` → 解压到 `~/`（tar 内已包含 `.vimrc`）

**打包规则（`paste_local_config.sh`，排除 `.git`/cache）：**
- `~/.bash_aliases` → `bash/bash_aliases`
- `~/.gitconfig` → `git/git.config`
- `.oh-my-zsh .zshrc .zsh_aliases .p10k.zsh` → `zsh/zsh_dotfile.tar`
- `~/.tmux/`（含 `tmux.conf`）→ `tmux/tmux_conf.tar` + 同步更新 `tmux/tmux.conf`
- `.vim .vim_runtime .vimrc` → `vim/vim_conf.tar` + 同步更新 `vim/vimrc`

### 安装 AI 开发环境：`nvm_nodejs_ai_harness/install`

此脚本记录了通过 nvm 安装 Node.js，再通过 npm 安装 Claude Code 的完整流程：

```bash
# 安装 nvm → Node.js v24.18.1 → Claude Code（全局）
npm install -g @anthropic-ai:claude-code
```

### 必备软件包：`sw_linux/list`

Ubuntu Jammy 下的推荐软件包列表（cmake、tmux、build-essential、python3 等），可通过 `apt install` 批量安装。

## 仓库结构

### C++ 项目（位于 `cpp_demo/` 目录）
- `cpp_demo/main.cpp` — C++ 演示，包含两种并行模式：
  - `PrintLine(nThread)` — 使用 `std::thread` 实现多线程并行打印
  - `PrintLine_MultiProcess(job_num)` — 使用 `fork()` + `wait()` 实现多进程，子进程调用 `PrintLineUnit()` 后 `exit(0)`，父进程 `wait(NULL)` 循环回收
  - 当前 `main()` 调用的是多进程版本，使用 3 个工作进程。每个进程/线程打印 100 行（区间边界为 `i * 100` 到 `(i + 1) * 100`）。
- `cpp_demo/CMakeLists.txt` — CMake 3.10+，编译目标 `exec_thread`，链接 `pthread`。开启 `-Wall -Wpedantic`。`file(GLOB_RECURSE SRC "./src/*.cpp" "./src/*.c")` 预留了 `src/` 目录的源码扩展（该目录当前不存在）。
- `cpp_demo/make_code` — CMake 构建脚本（见上文「构建与运行」）。
- `cpp_demo/quick_make_code/` — 单文件快速编译工具（`make_code.cpp` + `build_cmd`）。

### 配置文件目录
| 目录 | 内容 |
|------|------|
| `bash/` | `.bash_aliases`（cmake/git/代理别名） |
| `git/` | `git.config`（全局 git 用户配置：编辑器、用户名、邮箱） |
| `tmux/` | tmux 配置文件（tar 包 + 独立 `.conf`） |
| `vim/` | vim 配置文件（tar 包） |
| `zsh/` | zsh 配置文件（tar 包）+ `zsh_help`（迁移注意事项） |
| `wsl/` | `.wslconfig`（镜像网络、自动内存回收、嵌套虚拟化）+ WSL 常用命令备忘 |
| `etc_apt_sources_list/` | Ubuntu Jammy 清华镜像源 |
| `sw_linux/` | 软件包列表 + pip 镜像配置 |

### WSL2 配置要点
- `wsl/wslconfig` 启用了镜像网络模式、DNS 隧道、渐进式自动内存回收 (`autoMemoryReclaim=gradual`)、嵌套虚拟化，以及 IPv6、防火墙和自动代理。
- 代理开关 `vpn_port`/`unvpn_port`（`bash/bash_aliases`）设置 `http_proxy`/`https_proxy` 指向 `192.168.0.1:7890`（`git.config` 本身不含代理配置）。
