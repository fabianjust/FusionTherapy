function [n_mov] = get_nmov(i_mov)
movements = {'abd','ele','rot','fle','mj1'};
n_mov = movements{i_mov};
if isempty(n_mov)
    msgID = 'get_imov:missing_movement';
    msg = [i_mov,' is not defined!'];
    throw(MException(msgID,msg))
end
end