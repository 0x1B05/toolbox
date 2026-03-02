#import "@local/notes:0.1.0": *

= quick hacks

== cheatsheet

- ncdu: 查看磁盘使用情况。`ncdu /`

== vim

=== Very Magic Mode

在 Vim 中，默认的正则表达式引擎需要对大部分特殊字符进行转义（如 `\+`、`\(`、`\{`），而使用 `\v`可以让你直接使用这些符号。

#example(title: "文本中的日期格式从 2023-10-24 更改为 24/10/2023")[

  ```vim
  :%s/\v(\d{4})-(\d{2})-(\d{2})/\3\/\2\/\1/g
  ```

  - *`\v`*: 开启 Very Magic，我们可以直接写 `()` 和 `{}` 而不需要写成 `\(\)` 和 `\{\}`。
  - *`(\d{4})`*: 第一组，匹配 4 个数字（年）。
  - *`(\d{2})`*: 第二、三组，分别匹配月和日。
  - *`\3\/\2\/\1`*: 替换部分。`\3` 代表第三个括号匹配的内容（日），以此类推。`\/` 是对斜杠的转义。
]

#example(title: "给文档中所有的 HTTP 链接加上反引号 `")[

  当不需要改变原始内容的顺序，只是想在其“外围”包裹东西时，使用 `&` 会比定义分组 `\1` 简洁得多。

  ```vim
  :%s/\vhttps?:\/\/[^ ]+/`&`/g
  ```

  - *`\v`*: 魔法模式，`?` 和 `+` 直接生效。
  - *`https?:\/\/[^ ]+`*: 匹配以 `http` 开头（`s` 可有可无），直到遇到第一个空格为止的字符串。
  - *`&`*:  代表上面正则匹配到的*整个完整字符串*。
  - *相比分组的优势*：如果用分组，得写成 `:%s/\v(http\S+)/`\1`/g`。用 `&` 省去了打括号的麻烦。
]

==== 搜索

- `/xxx` 向下搜索`xxx`，`?xxx` 向上搜索`xxx`
- `#` 向上搜索当前光标所在单词，`*`向下搜索光标所在单词（全字匹配）
- `g#` 向上搜索当前光标所在单词，`g*`向下搜索光标所在单词（部分匹配）

#figure(caption: "核心对比表")[
  #three-line-table[
    | 命令 | 搜索方向 | 匹配模式 | 示例 (光标在 `the` 上) |
    | --- | --- | --- | --- |
    | *`*`* | 向下 | *全字* | 只匹配 `the` |
    | *`#`* | 向上 | *全字* | 只匹配 `the` |
    | *`g*`* | 向下 | *部分* | 匹配 `the`, `there`, `other` |
    | *`g#`* | 向上 | *部分* | 匹配 `the`, `there`, `other` |
  ]
]

#note-box(title: "为什么要用 g*？")[
  如果你在查看一段代码，光标在一个变量名 `user` 上，你想快速找到所有包含这个字符的函数（比如 `get_user` 或 `user_list`），直接按 `g*` 会比手动输入 `/user` 快得多。
]

#tip-box[
  可将`?`与`q/`命令结合，调出搜索历史窗口进行交互式选择。
]

=== misc

```
set {option}? => 查询选项
echo &{option} => 计算表达式并打印
```

```
:lua print(vim.inspect(package.path))
:echo &rtp
:set rtp?
```

调出所有的命令历史，normal模式下`q:`

==== Insert new lines without hitting Enter

normal下按下`o`之后`<C-j>`就不需要按enter了

==== 一次性的normal mode

insert下`<C-o>`可进入一次性的normal，然后执行一个命令之后自动切换回insert

==== jumplist

`:ju[mps]` 可以查看jumplist

normal下，`<C-o>` go backward jumplist，`<C-i>` go forward jumplist

==== marks

`:marks`

==== vimgrep

```vim
:vimgrep /{pattern}/[g][j] {file} ...
```

- *`{pattern}`*: 搜索的内容（支持 Vim 正则表达式）。
- *`g` (global)*: 一行若有多个匹配，全部记录（不加则每行只记录第一个）。
- *`j` (just)*: 搜索后*不*自动跳转到第一个匹配点（默认会自动跳过去）。
- *`{file}`*: 目标文件。支持通配符，如 `*/*.py` 表示递归搜索目录下所有 Python 文件。

#figure(caption: "常用操作实例")[
  #three-line-table[
    | 场景 | 命令 |
    | --- | --- |
    | *在当前文件搜索* | `:vimgrep /error/ %` |
    | *在当前目录下所有文本文件搜索* | `:vimgrep /TODO/ *.txt` |
    | *递归搜索当前目录及子目录* | `:vimgrep /class/ */*` |
    | *搜索多个特定后缀的文件* | `:vimgrep /function/ */*.js */*.ts` |
    | *静默搜索（不跳转）* | `:vimgrep /debug/j %` |
  ]
]

`:vimgrep` 执行完后，匹配项会保存在 *Quickfix List*。你需要配合以下命令来使用：

- *`:copen`*: 打开 Quickfix 窗口。
- *`:cn[ext]`*: 跳转到下一个匹配项。
- *`:cp[rev]`*: 跳转到上一个匹配项。
- *`:cclose`*: 关闭 Quickfix 窗口。

#tip-box(title: "借助vimgrep批量替换")[
  `:cdo s/<origin>/<subsitution>/gc` 这里`c` for confirm
]

== pacman

- `sudo paccache -r` : 保留最近 3 个版本缓存
- `pacman -Qs <keywords>` : 查询包含keywords的包

== sed

```
sed -i 's|#import "../template.typ": \*|#import "@local/notes:0.1.0": \*|g; s|#tip-box(title: |#tip-box(title: |g; s|#example(title: |#example(title: title: |g' *.typ
```

== git

=== upstream

设置上游分支: `git branch --set-upstream-to=origin/br2 br1`，后面的`br1`是本地分支名
查看上游分支: `git branch -vv`

=== `git format-patch`

- Create an auto-named `.patch` file for all the unpushed commits:
  `git format-patch origin`

- Write a `.patch` file for all the commits between 2 revisions to `stdout`:
  `git format-patch revision_1..revision_2`

- Write a `.patch` file for the 3 latest commits:
  `git format-patch -3`

=== `git apply`

`git apply --directory=... path/to/file`
- Print messages about the patched files:
  `git apply --verbose path/to/file`
- Output diffstat for the input and apply the patch:
  `git apply --stat --apply path/to/fi`

=== lazygit

- `s`->stash
- `g`->pop stash
- `<C-S>` 筛选文件
- `<C-p>` custom patch选项

== docker

== ccache

== proxy

```
x ss -tlnp
State   Recv-Q  Send-Q    Local Address:Port      Peer Address:Port  Process
LISTEN  0       4096            0.0.0.0:5355           0.0.0.0:*
LISTEN  0       4096         127.0.0.54:53             0.0.0.0:*
LISTEN  0       4096          127.0.0.1:52345          0.0.0.0:*
LISTEN  0       4096          127.0.0.1:20172          0.0.0.0:*
LISTEN  0       4096          127.0.0.1:20171          0.0.0.0:*
LISTEN  0       4096          127.0.0.1:20170          0.0.0.0:*
LISTEN  0       4096      127.0.0.53%lo:53             0.0.0.0:*
LISTEN  0       4096          127.0.0.1:42229          0.0.0.0:*
LISTEN  0       4096               [::]:5355              [::]:*
LISTEN  0       4096                  *:2017                 *:*
```

```
> curl -x socks5h://127.0.0.1:20170 -I https://github.com
HTTP/2 200
...
```

```
ProxyCommand nc -X 5 -x 127.0.0.1:20170 %h %p
```
