if exists('loaded_CloseIt') || &cp || version < 700 || !has("python")
    finish
endif

function! CloseItForMe()
py << ENDPY
import vim

pairs_dict  = {'(':')', '[':']', '<':'>', '{':'}'}
parens      = ('(', ')', '[', ']', '<', '>', '{', '}')
left_parens = ('(', '[', '<', '{')

def split_at(s, idx):
    lhs    = s[:idx]
    center = s[idx]
    rhs    = s[idx+1:]
    return lhs, center, rhs

def rfind_first_unmatched_pair(s):
    paren_stack = ""
    r = reversed(s)
    
    for c in r:
        if c in parens:
            if c in left_parens:
                if len(paren_stack) == 0:
                    return c
                elif pairs_dict[c] == paren_stack[-1]:
                    paren_stack = paren_stack[:-1]
                else:
                    return None
            else:
                paren_stack += c

    return None

line_num, col_num = vim.current.window.cursor

lhs, center, rhs = split_at(vim.current.line, col_num+1)

unmatched = rfind_first_unmatched_pair(lhs)

if unmatched:
    match = pairs_dict[unmatched]

    if match != center:
        vim.current.line = lhs + match + center + rhs

    vim.current.window.cursor = line_num, col_num+1

ENDPY
endfunction

command! -nargs=0 CloseItForMe call CloseItForMe()

imap <C-k> <ESC>:CloseItForMe<CR>a
