function [i_mvc] = compute_mvc(MVC,i_mus)
m_data = load(MVC);
i_data = m_data.Data{i_mus+1};
i_data = abs(i_data);
i_mvc = mean(i_data);
end