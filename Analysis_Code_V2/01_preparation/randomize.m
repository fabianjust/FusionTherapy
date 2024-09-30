function [] = randomize()

rand_indices = randperm(3)
names_template = {'abd','fle','mj1'};
names_randomized(1,1:3) = {names_template{rand_indices}};

for i=1:3
    rand_indices = randperm(2);
    names_template = {'Conventional','Roboter'};
    names_randomized(2:3,i) = {names_template{rand_indices}};
end

LOC = uigetdir(pwd,'Enter subject folder');
save([LOC,'\randomization.mat'],'names_randomized')

end