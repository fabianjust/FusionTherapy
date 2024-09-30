function [i_con] = get_icon(n_con)

switch n_con
    case 'conb'
        i_con = 1;
    case 'cont'
        i_con = 2;
    case 'robb'
        i_con = 3;
    case 'robt'
        i_con = 4;
    case 'bri'
        i_con = 5;
    otherwise
        error('evaluate_subject:internal_error',...
            strcat(n_con,', ',exp_files(i).condition,': no matching case scenario'))
    end

end