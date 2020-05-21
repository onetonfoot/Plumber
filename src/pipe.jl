using ExprManipulation

has_unscores(expr::Expr) = any(map(has_unscores, expr.args))
has_unscores(x) = x == :_ ? true : false

function add_fn(expr)
    symbol = gensym()
    new_expr = transform(x->x == :_ ? symbol : x, expr)
    :($symbol->$new_expr)
end

slurp = Slurp(:args) do args
    any(has_unscores.(args))
end

capture_pipe = Capture(:pipe) do expr
    expr in [:|> , :.|>]
end

match_underscores = MExpr(Capture(:head), slurp)
match_pipe = MExpr(:call, capture_pipe, Capture(:fn), Slurp(:args))

function pipe(expr)
    transform(expr) do expr
        matches = match(match_pipe, expr)
        if !isnothing(matches)
            fn = matches[:fn]
            args = matches[:args]
            pipe = matches[:pipe]
            args = map(arg->match_underscores == arg ? add_fn(arg) : arg, args)
            Expr(:call, pipe, fn, args...)
        else
            expr
        end
    end
end

macro pipe(expr)
    esc(pipe(expr))
end