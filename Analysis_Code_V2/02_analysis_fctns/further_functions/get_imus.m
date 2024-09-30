function [i_mus] = get_imus(n_mus)
switch n_mus
    case 'ut'
        i_mus = 1;
    case 'pd'
        i_mus = 2;
    case 'ad'
        i_mus = 3;
    case 'pm'
        i_mus = 4;
    case 'bb'
        i_mus = 5;
    case 'lt'
        i_mus = 6;
    otherwise
        msgtext = 'No muscle name saved in this convention';
        msgID = 'get_imus:muscle_not_found';
        ME = MException(msgID,msgtext);
        throw(ME)
end
        

end