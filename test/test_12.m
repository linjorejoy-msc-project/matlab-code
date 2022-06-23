format compact
clear
clc

cellvec = {[2 3], 0, [1 2 3], [2 2 -3]};

sparse2matrix(cellvec)

function return_mat = sparse2matrix(cellvec)
    matrix(1:cellvec{1}(1), 1:cellvec{1}(2)) = cellvec{2}
    for n = 3:length(cellvec)
        cur_arr = cellvec{n};
        matrix(cur_arr(1), cur_arr(2)) = cur_arr(3);
    end
    return_mat = matrix;
end