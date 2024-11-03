# shgen
tiny posix shell templating engine.

## example
**foo.shtml**
```html
$(cat './partials/header.html')

<p>$(ternary "[ 5 -lt 3 ]" 'true' 'false')</p>

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
usage: shgen [OPTIONS] file...

options:
  -o, --output    <dir>  output directory (optional)
  -e, --extension <ext>  output extension (required with -o)
  -h, --help             show this help message

examples:
  shgen foo.shtml > bar.html
  shgen ./input/*.shtml -o output/ -e txt
  shgen a.shtml b.shtml -o output/ -e html
```
