function [n_con] = get_ncon(i_con)
switch i_con
    case 1
        n_con = 'conb';
    case 2
        n_con = 'cont';
    case 3
        n_con = 'robb';
    case 4
        n_con = 'robt';
    case 5
        n_con = 'bri';
    otherwise
        error('evaluate_subject:internal_error',...
            strcat(n_con,', ',exp_files(i).condition,': no matching case scenario'))
    end
end