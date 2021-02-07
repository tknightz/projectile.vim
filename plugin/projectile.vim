if exists('g:projectile_loaded')
    finish
endif

let g:projectile_loaded = 1

function! Change_Dir(...)
  let paths = split(a:1)
  let g:workplace_name = paths[2]
  let g:workplace_path = paths[4]
  exec "cd " . paths[4]
  if exists("g:NERDTree")
    silent exec ":NERDTreeCWD"
  endif
endfunction

function! g:List_Projects()
  if !filereadable($HOME . '/.config/nvim/.projects')
    call writefile([], $HOME . '/.config/nvim/.projects', '')
  endif
  let projects = readfile($HOME . '/.config/nvim/.projects')
  call map(projects, {k,v -> k . '   ' . split(v)[0] . '  ' . split(v)[1]})
  return fzf#run(fzf#wrap({ 
        \'source': extend(['Id Project       Path'], projects), 
        \'sink': function('Change_Dir'),
        \'options': '+m --ansi --tiebreak=begin --header-lines=1'}))
endfunction


function! s:Save_Project(...)
  let project_path = g:directory . a:1[0]
  let project_git_root = system('git -C ' . project_path . ' rev-parse --show-toplevel 2> /dev/null')[:-2]
  if strlen(project_git_root) > 2
    call writefile([g:project_name . "\t\t" . project_git_root], $HOME . '/.config/nvim/.projects', 'a')
  else
    call writefile([g:project_name . "\t\t" . project_path], $HOME . '/.config/nvim/.projects', 'a')
  endif
  redraw!
  echohl WarningMsg
  echo "Created project ".g:project_name
  echohl None
endfunction

function! s:Previous_Dir(...)
  call feedkeys('i')
  let g:directory = system('dirname '.g:directory)[:-2] . '/'
  echo g:directory
  call fzf#run(fzf#wrap({ 
        \'source': 'find ' . g:directory . ' -maxdepth 1 -type d | sed "s:^"'.g:directory.'::', 
        \'options': '--tiebreak=begin --header-lines=1 --prompt='.g:directory}))
endfunction

function! s:Select_Dir(...)
  call feedkeys('i')
  let g:directory .= a:1[0] . '/'
  call fzf#run(fzf#wrap({ 
        \'source': 'find ' . g:directory . ' -maxdepth 1 -type d | sed "s:^"'.g:directory.'::', 
        \'options': '+m --ansi --tiebreak=begin --prompt='.g:directory}))
endfunction

function! g:Add_Project()
  call inputsave()
  echohl WarningMsg
  let g:project_name = substitute(input("  Project's name: "), " ", "", "g")
  echohl None
  if strlen(trim(g:project_name)) < 2
    redraw!
    echohl ErrorMsg
    echo "Wrong name!"
    echohl None
    return 
  endif
  call inputrestore()

  let g:directory = $HOME.'/'
  
  let g:fzf_action = {
        \'tab': function('s:Select_Dir'),
        \'enter': function('s:Save_Project'),
        \'shift-tab': function('s:Previous_Dir'),
        \}
  let project_path = fzf#run(fzf#wrap({ 
        \'source': 'find ~ -maxdepth 1 -type d | sed "s:^'.g:directory.'::"', 
        \'options': '+m --ansi --tiebreak=begin --header-lines=1 --prompt='.g:directory}))
endfunction

function! Edit_File(...)
  let file_name = a:1

  if g:show_files_project 
    exec ':e '.file_name
    return
  endif

  let s:current_file_path = expand('%:p:h')
  let s:current_project = system('git -C '. s:current_file_path . ' rev-parse --show-toplevel 2> /dev/null')[:-2]
  if len(s:current_project)
    exec ':e '.s:current_project.'/'.file_name
  else
    exec ':e '.s:current_file_path.'/'.file_name
  endif
endfunction

function! Show_Files(...)
  let s:path = a:1
  let s:prompt_name = 'Files'
  if exists('g:workplace_path')
    if s:path == g:workplace_path
      let s:prompt_name = g:workplace_name
    endif
  endif
    
  call fzf#run(fzf#wrap({
  \'source': 'rg --files --hidden -g "!{.git,node_modules}" '.s:path. ' | sed "s:^"'.s:path.'/::',  
  \'sink': function('Edit_File'),
  \'options': "--preview 'bat --style=numbers --color=always ".s:path."/$(<<< {}) ' --delimiter=/ --nth=-1,1,2,3 --tiebreak=begin --prompt='  ".s:prompt_name." >> '"}))

endfunction

function! g:Current_File_Proj()
  let g:show_files_project = 0
  let s:current_file_path = expand('%:p:h')
  let s:current_project = system('git -C '. s:current_file_path . ' rev-parse --show-toplevel 2> /dev/null')[:-2]
  if len(s:current_project) > 0
    call Show_Files(s:current_project)
  else
    call Show_Files(s:current_file_path)
  endif
endfunction

function! g:Find_In_Project()
  if exists('g:workplace_path') == 1
    let g:show_files_project = 1
    call Show_Files(g:workplace_path)
  else
    echo "You're not in project!"
  endif
endfunction


function! s:Delete_Project(...)
  if !filereadable($HOME . '/.config/nvim/.projects')
    call writefile([], $HOME . '/.config/nvim/.projects', '')
  endif
  let projects = readfile($HOME . '/.config/nvim/.projects')
  let line = split(a:1)
  let path = str2nr(line[0]) 

  echohl Question
  echo "Are you sure to delete " . split(projects[path])[0] . "? (Y)es/(n)o?"
  echohl None

  let choice = nr2char(getchar())
  if choice == 'y'
    redraw!
    echohl WarningMsg
    echo "Removed " . split(projects[path])[0]
    echohl None
    call remove(projects, path, path)
    call writefile(projects, $HOME . '/.config/nvim/.projects')
  elseif choice == 'n'
    echohl WarningMsg
    echo "Cancelled!"
    echohl None
    return
  endif
endfunction

function! g:Remove_Project()
  if !filereadable($HOME . '/.config/nvim/.projects')
    call writefile([], $HOME . '/.config/nvim/.projects', '')
  endif
  let projects = readfile($HOME . '/.config/nvim/.projects')
  call map(projects, {k,v -> k . '   ' . split(v)[0] . '   ' . split(v)[1]})
  return fzf#run(fzf#wrap({ 
        \'source': projects, 
        \'sink': function('s:Delete_Project'),
        \'options': '-m --prompt="  Remove Project  "'}))
endfunction

command! AddProject :call g:Add_Project()
command! ListProject :call g:List_Projects()
command! RemoveProject :call g:Remove_Project()
