module Plumber

export @pipe

using MLStyle
using MacroTools: prewalk, postwalk, alias_gensyms
using Base.Iterators: flatten

function has_underscores(expr)
    res = @match expr begin
        :_ => true
        Expr(head,args...) => has_underscores.(args)
        _ => false
    end
    res |> flatten |> any
end

function remove_underscores!(expr)
    if has_underscores(expr)
        local f = gensym()
        expr = postwalk(x -> x == :_ ? f : x , expr)
        :($f -> $expr)
    else
        expr
    end
end

function mutate_pipes!(expr)
    @match expr begin
        Expr(:call, :|>, before, after) => Expr(:call,:|>,mutate_pipes!(before) ,mutate_pipes!(after))
        Expr(:call, :.|>, before, after) => Expr(:call,:.|>,mutate_pipes!(before) ,mutate_pipes!(after))
        Expr(:->,_...) => expr
        Expr(_, _, args...) => remove_underscores!(expr)
        _ => expr
    end
end

macro pipe(expr)
    esc(mutate_pipes!(expr))
end

end
