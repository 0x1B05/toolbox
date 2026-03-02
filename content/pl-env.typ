#import "@local/notes:0.1.0": *

= programming-language-env

== rust

```
sudo pacman -S rustup
rustup default stable
```

```
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"
export PATH="$HOME/.cargo/bin:$PATH"
```

```
[source.crates-io]
replace-with = 'rsproxy'

[source.rsproxy]
registry = "sparse+https://rsproxy.cn/index/"

[source.rsproxy-sparse]
registry = "sparse+https://rsproxy.cn/index/"

[registries.rsproxy]
index = "https://rsproxy.cn/crates.io-index"

[net]
git-fetch-with-cli = true
```

== python

=== uv

```
sudo pacman -S uv
```

`uv` 是一个极其快速的 Python 包和版本管理器，旨在替代 `pip`、`pip-tools`、`venv`、`poetry` 和 `pyenv`。

#three-line-table[
  | 场景 | 命令 | 备注 |
  | --- | --- | --- |
  | *安装 Python 版本* | `uv python install 3.12` | 无需 pyenv，自动下载并管理多版本 |
  | *创建虚拟环境* | `uv venv` | 在当前目录快速创建 `.venv` 文件夹 |
  | *激活环境* | `source .venv/bin/activate` | 标准激活方式 |
  | *安装包* | `uv add <pkg>` | 自动创建/更新 `pyproject.toml` 并安装依赖 |
  | *运行脚本* | `uv run <script.py>` | 自动在当前项目的虚拟环境中执行 |
  | *单文件运行* | `uv run --with requests script.py` | *强大功能*：无需建环境，临时安装依赖并运行 |
  | *同步依赖* | `uv sync` | 严格根据 `uv.lock` 文件同步本地环境 |
  | *一键清理* | `uv cache clean` | 清理 uv 的全局缓存以节省空间 |
]

== chisel

```
paru -S mill coursier-bin
```

```
git clone https://github.com/OSCPU/chisel-playground
cd chisel-playground
make test
make verilog
```

```
nvim .
:MetalsInstall
```
