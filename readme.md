# shgen
tiny posix shell templating engine.

## example
**foo.shtml**
```html
$(cat './partials/header.html')

<p>$([ 5 -lt 3 ] && echo 'true' || echo 'false')</p>

<ul>
$(loop "$(ls)" '<li>$index is <b>$item</b></li>')
</ul>
```

**./partials/header.html**
```html
<header>
  <h1>shgen</h1>
</header>
```

run it like this: `shgen foo.shtml`

**output**
```html
<header>
  <h1>shgen</h1>
</header>

<p>false</p>

<ul>
<li>0 is <b>foo.shtml</b></li>
<li>1 is <b>header.html</b></li>
</ul>
```

## usage
```sh
usage: shgen [FILE]

options:
  -h, --help    show this help message

examples:
  shgen template.txt      # process a file
  cat file.txt | shgen    # process from stdin
```

_**note:** only lines containing `$` will be evaluated.
use 'single quotes' for strings outside of $(command substitutions) or escape backticks and double quotes with backslash._
