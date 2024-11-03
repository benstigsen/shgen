# shgen
tiny posix shell templating engine.

## example
**foo.shtml**
```html
$(cat 'header.html')

<p>$(ternary "[ 5 -lt 3 ]" 'true' 'false')</p>

<ul>
$(loop "$(ls)" '<li>$index is <b>$item</b></li>')
</ul>
```

**header.html**
```html
<header>
  <h1>shgen</h1>
</header>
```

run it like this: `shgen *.shtml output/ html`

**output/foo.html**
```html
<header>
  <h1>shgen</h1>
</header>

<p>false</p>

<ul>
<li>0 is <b>foo.shtml</b></li>
<li>1 is <b>header.html</b></li>
</ul>
