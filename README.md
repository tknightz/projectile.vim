
# Table of Contents

1.  [Projectile.vim](#orgbebd8f3)
    1.  [Installation](#orgcd6c29d)
        1.  [Required](#org96181ef)
        2.  [Using vim-plug](#orgc899737)
        3.  [Commands](#org36a0ab2)
    2.  [Demo](#orgb78f13d)
    3.  [License](#org03c5004)



<a id="orgbebd8f3"></a>

# Projectile.vim

Inspiring from Projectile Emacs


<a id="orgcd6c29d"></a>

## Installation


<a id="org96181ef"></a>

### Required

projectile.vim require fzf.vim to work correctly.

-   Install ****fzf.vim**** if you haven&rsquo;t install it yet : <https://github.com/junegunn/fzf.vim#installation>


<a id="orgc899737"></a>

### Using vim-plug

```vimscript
Plug 'tknightz/projectile.vim'
```


<a id="org36a0ab2"></a>

### Commands

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Command</th>
<th scope="col" class="org-left">Detail</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">:AddProject</td>
<td class="org-left">Add new project to Vim.</td>
</tr>


<tr>
<td class="org-left">:ListProject</td>
<td class="org-left">List all projects stored in Vim.</td>
</tr>


<tr>
<td class="org-left">:RemoveProject</td>
<td class="org-left">Remove project exists.</td>
</tr>
</tbody>
</table>

> Mapping to your own

    nmap ;pa :AddProject<CR>
    nmap ;pl :ListProject<CR>


<a id="orgb78f13d"></a>

## Demo


<a id="org03c5004"></a>

## License

GPL v2.0

