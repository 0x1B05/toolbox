#import "@local/notes:0.1.0": *

#show: notes.with(
  title: [ 0x1B05's Toolbox ],
  short_title: "toolbox",
  abstract: [
    This notebook serves as a curated repository of technical insights and engineering workflows, bridging the gap between fleeting terminal commands and deep system mastery. It chronicles a collection of "muscle memory" hacks and systematic deep-dives across the modern developer stack—ranging from low-level debugging with GDB and binary instrumentation to high-efficiency environment configurations for Python and C++.
  ],
  date: datetime(year: 2025, month: 1, day: 8),
  authors: (
    (
      name: "0x1B05",
      link: "https://github.com/0x1B05",
    ),
  ),

  bibliography-file: none,
  paper_size: "a4",
  font: (
    "Tex Gyre Termes",
    "Noto Serif CJK SC",
  ),
  code_font: "FiraCode Nerd Font Mono",
  toc: true,
)

#include "content/ccache.typ"
#include "content/debug.typ"
#include "content/quick-hacks.typ"
#include "content/pl-env.typ"
