format compact
global xvar;
xvar = containers.Map;
xvar

test_global()
xvar

function test_global()
    global xvar;
    xvar('one') = 1;
end