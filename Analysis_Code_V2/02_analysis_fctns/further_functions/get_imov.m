function [i_mov] = get_imov(n_mov)
movements = {'abd','ele','rot','fle','mj1'};
i_mov = find(strcmp(movements,n_mov));
if isempty(i_mov)
    msgID = 'get_imov:missing_movement';
    msg = [n_mov,' is not defined!'];
    throw(MException(msgID,msg))
end
end