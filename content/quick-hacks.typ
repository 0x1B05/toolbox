#import "@local/notes:0.1.0": *

= quick hacks

== cheatsheet

- ncdu: 查看磁盘使用情况。`ncdu /`

== vim

=== Very Magic Mode

`⟨...⟩`都用反引号包裹

```vim
:%s/\v(⟨[^⟩]+⟩)/`\1`/g
```

- *Very Magic (`\v`)*: 简化正则语法，避免大量反斜杠。默认的正则表达式模式需要对 `(`、`)`、`+` 等符号进行大量转义（如 `\(\)`）。开启 `\v` 后，除了字母、数字和下划线，所有特殊字符都自动具备“魔法”含义。
- `[^⟩]+` 表示匹配一个或多个不是 `⟩`的任意字符，确保匹配在遇到结束括号时停止。
- *Capture Group (`\1`)*: 捕获 `⟨...⟩` 并在替换时通过 `\1` 还原。

当不需要分组的时候把`\1`换成`&`更高效，`&`(也可以是`\0`)代表正则表达式在当前行匹配到的完整原始字符串。

- 分组：数据清洗、格式转换、重构代码
- 全局引用：加前后缀、整体替换

=== tips

`#` 向上搜索系统粘贴板的内容？
（`/` 向下搜索，`?` 向上搜索）
实际开发中可将`?`与`q/`命令结合，调出搜索历史窗口进行交互式选择。

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

== pacman

`sudo paccache -r` : 保留最近 3 个版本缓存

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
