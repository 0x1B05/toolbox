#import "@local/notes:0.1.0": *

= 调试理论

- *机器永远是对的*
- *未测代码永远是错的*

= 技巧

- `ssh`：使用 `-v` 选项检查日志
- `gcc`：使用 `-v` 选项打印各种过程
- `make`：使用 `-n` 选项查看完整命令
- `make -nB | grep -ve '^\(echo\|mkdir\)'` 可以查看完整编译 nemu 的编译过程

#example(title: "找不到sys/cdefs.h")[
  `'sys/cdefs.h': No such file or directory`，找不到文件 (这看起来是用 `perror()` 打印出来的哦！)

  - `#include` = 复制粘贴，自然会经过路径解析
  - (折腾 20 分钟) 明明 `/usr/include/x86_64-linux-gnu/sys/cdefs.h` 是存在的 (`man 1 locate`) → 极度挫败，体验极差

  推理：`#include <>` 一定有一些搜索路径

  - 为什么两个编译选项，一个通过，一个不通过？
    - `gcc -m32 -v` v.s. `gcc -v`
]

=== `-fsanitize=address`: Address Sanitizer

是否希望在每一次指针访问时，都增加一个断言: `assert(obj->low <= ptr && ptr < obj->high);`

```c
int *ref(int *a, int i) {
  return &a[i];
}

void foo() {
  int arr[64];
  *ref(arr, 64) = 1; // bug
}

int main(){
    foo();
}
```

一个神奇的编译选项: `-fsanitize=address`. Address Sanitizer; asan “动态程序分析”.相当于在运行的时候加了Assert.

```sh
❯ gcc test.c -o test
❯ ./test
❯ gcc test.c -fsanitize=address -o test
❯ ./test
=================================================================
==1403==ERROR: AddressSanitizer: stack-buffer-overflow on address 0x7ffd71347d60 at pc 0x5645c5cb22d6 bp 0x7ffd71347c30 sp 0x7ffd71347c20
WRITE of size 4 at 0x7ffd71347d60 thread T0
    #0 0x5645c5cb22d5 in foo (/home/liuheihei/tmp/test+0x12d5)
    #1 0x5645c5cb2392 in main (/home/liuheihei/tmp/test+0x1392)
    #2 0x7f614efdcd8f in __libc_start_call_main ../sysdeps/nptl/libc_start_call_main.h:58
    #3 0x7f614efdce3f in __libc_start_main_impl ../csu/libc-start.c:392
    #4 0x5645c5cb2104 in _start (/home/liuheihei/tmp/test+0x1104)

Address 0x7ffd71347d60 is located in stack of thread T0 at offset 288 in frame
    #0 0x5645c5cb21fd in foo (/home/liuheihei/tmp/test+0x11fd)

  This frame has 1 object(s):
    [32, 288) 'arr' (line 4) <== Memory access at offset 288 overflows this variable
HINT: this may be a false positive if your program uses some custom stack unwind mechanism, swapcontext or vfork
      (longjmp and C++ exceptions *are* supported)
SUMMARY: AddressSanitizer: stack-buffer-overflow (/home/liuheihei/tmp/test+0x12d5) in foo
Shadow bytes around the buggy address:
  0x10002e260f50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x10002e260f60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x10002e260f70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x10002e260f80: 00 00 00 00 00 00 00 00 f1 f1 f1 f1 00 00 00 00
  0x10002e260f90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
=>0x10002e260fa0: 00 00 00 00 00 00 00 00 00 00 00 00[f3]f3 f3 f3
  0x10002e260fb0: f3 f3 f3 f3 00 00 00 00 00 00 00 00 00 00 00 00
  0x10002e260fc0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x10002e260fd0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x10002e260fe0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x10002e260ff0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
Shadow byte legend (one shadow byte represents 8 application bytes):
  Addressable:           00
  Partially addressable: 01 02 03 04 05 06 07
  Heap left redzone:       fa
  Freed heap region:       fd
  Stack left redzone:      f1
  Stack mid redzone:       f2
  Stack right redzone:     f3
  Stack after return:      f5
  Stack use after scope:   f8
  Global redzone:          f9
  Global init order:       f6
  Poisoned by user:        f7
  Container overflow:      fc
  Array cookie:            ac
  Intra object redzone:    bb
  ASan internal:           fe
  Left alloca redzone:     ca
  Right alloca redzone:    cb
  Shadow gap:              cc
==1403==ABORTING
```

= gdb

- `-g1` => 最低级别(基本行号，函数名，变量类型信息)
- `-g2` => 中等(默认`-g`)(完整行号，函数，变量，结构体布局)
- `-g3` => 最高级别(额外包含宏定义，内联函数，模板实例化信息) 文件要大很大。
- `-q` => quiet, 界面干净一些。

- `file xx`=>可以查看有没有调试信息，如果有`with debug_info`就代表有调试信息。
- 按`<Enter>`可以直接重复上一次命令。

== 基础操作

- `run`/`r`: `run [arglist]`运行
- `break`/`b`: `b [file:][linenum]`
- `info breakpoints`/`i b`
- `print`
- `next`/`n`: 显示出来的代码是没有执行的(即下一行), 跳过函数调用
- `step`/`s`: 显示出来的代码是没有执行的(即下一行), 进入函数调用
- `continue`/`c`: 继续执行程序（在停止之后，例如断点之后），直到下一个断点或程序结束。
- `finish`: 继续执行，直到将*当前函数*返回，并把函数的返回值打印
- `return`: 强制退出当前函数的调用(不执行后面的代码)，直接返回调用位置
- `shell`/`!`: 不离开gdb就可以执行shell命令
- `watch`/`w`:监视某个变量，被改变的时候停下来(`i wat`可以展示观察点信息)
- `nexti`/`ni`: 执行下一行源代码中的第一条汇编（`disassemble`查看汇编）仍跳过函数调用
- `stepi`/`si`: 执行下一行源代码中的第一条汇编（`disassemble`查看汇编）仍进入函数调用

#tip-box(title: "硬件观察点 vs. 软件观察点")[
  - 硬件观察点：硬件直接执行（执行效率非常高，但是数量受限）
  - 软件观察点：软件通过中断执行
]

== 断点

```
break <行号>
break <文件名>:<行号>

break <函数名>
break <类名>::<函数名>
break <文件名>:<函数名>

delete <断点编号> # d <断点编号>
disable <断点编号>
enable <断点编号>
enable once <断点编号> # 启动一次后自动禁用

break <位置> if <条件表达式>

tbreak <位置> // tb临时断点, 语法与break相同, 击中一次后被删除
break *<内存地址>
rb <模糊函数名> // 正则匹配
```

#tip-box(title: "Tip")[
  - 如果函数名有重合的话，可以`b <重合部分>`然后回车，就可以看到相关联的所有函数。
  - `d`单个命令是删除所有断点
  - tab可以补全
  - 平时不要随意删除断点，可以通过`disable`或者`enable`进行使能控制。
  - `enable once`经常和条件断点混合使用
  - `b`=>未击中，`B`击中.`+`=>enable, `-`=>disable. `B+`已经被击中的enable的断点。
]

=== 断点命令

```
break <位置>
commands <断点编号> # 定义断点命令
  <命令1>
  <命令2>
end

commands <断点编号> # 修改断点命令
  <新命令..>
end

commands <断点编号>
end
```

#example(title: "Example")[
  ```c
  int sum = 10;
  for (int i = 0; i < 10; i++){
    sum += i;
  }
  ```

  ```gdb
  commands 1<enter>
  >p i
  >p sum
  >c
  >end
  ```

  ```gdb
  commands 1<enter>
  >if i>5 && i<9
    >printf "i:%d, sum:%d\n", i, sum
    >else
    >c
    >end
  >end
  ```

  ```gdb
  commands 1<enter>
  >silent # 静默断点信息打印
  >if i>5 && i<9
    >printf "i:%d, sum:%d\n", i, sum
    >end
  >c
  >end
  ```

  #tip-box(title: "Tip")[
    `commands`不加编号就是默认最近打的断点。
  ]
]

- `svae breakpoints bk.gdb`: 保存断点信息
- `source bk.gdb`: 保存断点信息(`bk.gdb`实际上就是一些文本信息，可以直接更改，没有严格的缩进。)

== .gdbinit

```
add-auto-load-safe-path PATH # 用户目录下新建可信任路径
curdir/.gdbinit
cmds
```

== 程序入参设置

```
            argv0  1   2      3
gdb --args ./test 123 abc "1 b 2 d" # 如果参数有空格就需要""
show args # 打印参数列表

r 123 abc "1 b 2 d" # gdb命令行里面
show args # 打印参数列表

set args 123 abc "1 b 2 d"
```

#tip-box(title: "Tip")[
  - gdb命令行里面`r arg1 ...`可以保持断点等gdb调试信息，换一套`args`调试。
  - gdb命令行里面`r arg1 ...`之后，再次`r`不加任何入参也会沿用前一次的入参。
]

== watch

- `watch`: 监视一个变量的值，变量值被写时stop
- `rwatch`: 监视一个变量的值，变量值被读时stop
- `awatch`: 监视一个变量的值，变量值被读/写时stop

== 栈

- `bt`: 程序堆栈信息
- `bt full`: 显示函数参数和局部变量的值
- `bt 3`: 只显示最近的3层调用(也可以`bt full <num>`)
- `info frame`/`i frame`: 查看当前栈帧信息
- `frame <frame_number>`：切换到指定的堆栈帧（例如 `frame 2`）。

#tip-box(title: "Tip")[ `i line <num>`可以查看具体某行代码的信息。 ]

== 打印

=== `display`

- `display <变量名>`：可以自动在每次程序暂停时显示变量的值。
- 查看已设置的 `display`：`info display`
- 删除 `display`：`undisplay <display编号>`

=== `print`

- `print x`：打印变量x的值(10进制)。
- `print /x ptr`：以十六进制显示指针的值。
- `print /d <变量>`：以十进制显示。
- `print /t <变量>`：以二进制显示。
- `print /s <变量>`：以字符形式显示。

- `print 'namespace::var'`打印命名空间中的变量
- `print 2*x+y`计算表达式
- `print func(a,b)`调用函数，需要确保安全
- `print MyClass::staticMethod()`调用静态方法

- `print *(int*)0x12345678`打印指定地址的int值
- `print (char*)0x4000000`将地址视为字符串

```
show print null-stop    # 默认遇到\0不停止打印
set print null-stop on  # 遇到\0停止打印

set print array on      # 启用数组格式化输出(每个元素都换行)
set print pretty on     # 启用结构体格式化输出
```

- `p $pc=0x80000000`: 控制程序从`0x80000000`开始执行(配合`i line <num>`使用)
- `p case=x`: 修改变量的值(控制配合`pc`重新回到`switch`的开头)

=== `ptype`

```
ptype <变量名>
ptype <类型名>
ptype <枚举类型>
ptype <数组名>
ptype <函数名>
```

```
set print object on  # 启用对象打印
set print object off # 禁用对象打印
show print object
ptype <基类指针>
info vtbl <指针变量>
```

```
ptype my_vector # 显示模板类型
ptype /r my_vector # 递归展开模板内部
ptype /o <类型名/变量名> # 显示类型的内存布局
```

== 源码查看

- `list`/`l`:
  - 代码向下浏览10行`l`(即`l +`)
  - 代码向上浏览10行`l -`
  - 浏览具体行数`l <linenum>`
  - 设置浏览行数`set listsize 30`(默认显示10行`show listsize`)
  - `l 函数名`显示指定函数的源码
  - `l 文件名:行号/函数`显示指定文件的特定行/函数
  - `l 5,10`显示5-10行

- `search 正则表达式`向前搜索匹配正则的代码行(查到之后直接用`l`可以看查看结果前后的代码)
- `reverse-search 正则`向后搜索匹配正则的代码行

- `i source`当前可执行程序的一些信息（编译目录等）
- `i sources`当前可执行程序包含了哪些文件

== layout

- `gdb -tui ./program`启动直接进入tui模式
- `layout src` 显示源码窗口
- `layout asm` 显示汇编窗口
- `layout regs` 显示寄存器窗口
- `layout split` 分屏显示源代码和汇编
- `layout next/prev` 多个布局之间切换

- `info win` 查看当前关注窗口
- `focus src/asm/regs`/`fs ...` 切换命令输入窗口

- `tui disable`(临时关闭)
- `tui enable`(重新打开，而是打开刚刚关闭的)
- `<Ctrl+x+a>`快捷切换tui模式

#tip-box(title: "Tip")[
  - 按↑↓只会在focus的窗口中移动，`fs cmd`可以聚焦到命令行窗口，就可以切换命令历史了
]

== 宏扩展

#tip-box(title: "Tip")[ 宏信息需要加`-g3` ]

`#define MAX (9988)`
- `macro expand MAX`
- `i macro MAX`

== 多线程

- `info threads`列出所有线程,标出当前线程`*`
- `thread`显示当前线程id和状态
- `thread <ID>`切换到指定线程

== 装载

`file [filename]`装入想要调试的可执行文件

== 与外部交互

`shell`/`!`
- `shell top`/`!top`
- `shell free`/`!free`
- `!ping www.baidu.com`

#tip-box(title: "Tip")[ gdb调试到一半的时候，并不想退出，想看一下外部的环境。 ]

=== 管道(pipe)过滤

#tip-box(title: "Tip")[
  - `i functions` => 输出很多
  - `pipe / | i functions | `
]

=== Starting:

查看变量
- `print <variable>` 或 `p <variable>`：打印变量的值（例如 `print x`）。
- `display <variable>`：每次程序暂停时自动打印变量的值。
- `info locals`：查看当前函数的所有局部变量。

修改变量
- `set var <variable>=<value>`：修改变量的值（例如 `set var x=10`）。

- 条件断点：在满足条件时触发断点。
  ```bash
  break main if x == 10
  ```
- 多线程调试：调试多线程程序。
  ```bash
  info threads
  thread <thread_id>
  ```
- 调试崩溃程序：分析核心转储文件。
  ```bash
  gdb ./my_program core
  ```
- `.gdbinit` 文件：GDB 启动时会自动加载 `~/.gdbinit` 文件或当前目录下的 `.gdbinit` 文件。你可以将常用命令写入该文件，例如：
  ```bash
  set breakpoint pending on
  set print pretty on
  ```

=== 命令历史

- `Ctrl + X + A` 退出 TUI 模式，恢复命令历史功能
- `layout src` 或 `layout asm` 可以切换回 TUI
- `Ctrl + P` / `Ctrl + N` 在 TUI 模式下仍可切换历史

==== 查看变量

3. 查看局部变量
使用 `info locals` 命令可以查看当前函数的所有局部变量。

语法：
```bash
info locals
```

4. 查看全局变量
使用 `info variables` 命令可以查看程序中的所有全局变量。

语法：
```bash
info variables
```

示例：
```bash
info variables   # 显示所有全局变量
```
5. 查看数组或结构体
- 查看数组：
  ```bash
  print array          # 查看整个数组
  print array[0]       # 查看数组的第一个元素
  print *array@10      # 查看数组的前 10 个元素
  ```

- 查看结构体：
  ```bash
  print my_struct      # 查看整个结构体
  print my_struct.field  # 查看结构体的某个字段
  ```
6. 查看寄存器中的值
使用 `info registers` 命令可以查看 CPU 寄存器的值。

```bash
info registers
```

示例：
```bash
info registers   # 显示所有寄存器的值
print $eax       # 查看特定寄存器（如 eax）的值
```
7. 查看内存中的值
使用 `x` 命令可以查看内存地址中的值。

语法：
```bash
x/<格式> <地址>
```

格式：
- `x`：十六进制。
- `d`：十进制。
- `u`：无符号十进制。
- `o`：八进制。
- `t`：二进制。
- `c`：字符。
- `s`：字符串。

示例：
```bash
x/4x 0x7fffffffe320  # 以十六进制显示内存地址 0x7fffffffe320 开始的 4 个字
x/10s 0x400000       # 显示内存地址 0x400000 开始的 10 个字符串
```

==== 查看当前进程打开了哪个文件

```
info proc
shelll ls -l /proc/xxx/fd
```

== makefile调试

#figure(
  ```makefile
  FILELIST_MK = $(shell find -L $(CSRC_DIR) -name "filelist.mk")
  $(info [DEBUG] FILELIST_MK = $(FILELIST_MK))
  include $(FILELIST_MK)
  ```,
  caption: [makefile - info],
)

查看当前makefile include了哪些makefile
- `$(info Makefiles included: $(MAKEFILE_LIST))`
- `make -p | grep "MAKEFILE_LIST"`
