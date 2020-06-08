# Plumber


Provides the `@pipe` macro which makes using the `|>` syntax a little nicer.
Instead of writing an anonymous function like so:


```julia
x = 10
f(x) = x^2
g(x,y) = x + y

x |> f |> x -> g(x,x)  

```

You can reference the output with a underscore:

```julia
x = 10
f(x) = x^2
g(x,y) = x + y

@pipe x |> f |> g(_,_)  
```

Any code that uses underscores will be transformed, adding an anonymous function:

```julia
x |> f |> whale->begin
            g(whale, whale)
        end
```    

Should work even for weird expressions.

```julia
x = 10
Pipe.@pipe(x |> [_,_] |> [_...,_...] ) == [10,10,10,10]
```


To install run:

```julia
] add Plumber
```

