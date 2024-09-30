function [n_mus] = get_nmus(i_mus, bool_fullname)
switch i_mus
    case 1
        if bool_fullname
            n_mus = 'Upper Trapezius';
        else
            n_mus = 'ut';
        end
    case 2
        if bool_fullname
            n_mus = 'Posterior Deltoid';
        else
            n_mus = 'pd';
        end
    case 3
        if bool_fullname
            n_mus = 'Anterior Deltoid';
        else
            n_mus = 'ad';
        end
    case 4
        if bool_fullname
            n_mus = 'Pectoralis Major';
        else
            n_mus = 'pm';
        end
    case 5
        if bool_fullname
            n_mus = 'Biceps';
        else
            n_mus = 'bb';
        end
    case 6
        if bool_fullname
            n_mus = 'Triceps';
        else
            n_mus = 'lt';
        end
    otherwise
        msgtext = 'No muscle name saved for this number';
        msgID = 'get_imus:muscle_not_found';
        ME = MException(msgID,msgtext);
        throw(ME)
end
        
end