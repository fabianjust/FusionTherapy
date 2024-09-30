 function [f_name] = getFullName(s_name)
            switch s_name
                case 'abd'
                    f_name = 'Abduction';
                case 'ele'
                    f_name = 'Shoulder Flexion';
                case 'rot'
                    f_name = 'Shoulder Rotation';
                case 'fle'
                    f_name = 'Elbow Flexion';
                case 'mj1'
                    f_name = 'Multi Joint';
                case 'pd'
                    f_name = 'Posterior Deltoid';
                case 'ad'
                    f_name = 'Anterior Deltoid';
                case 'ut'
                    f_name = 'Upper Trapezius';
                case 'bb'
                    f_name = 'Biceps Brachii';
                case 'lt'
                    f_name = 'Lateral Triceps';
                case 'pm'
                    f_name = 'Pectoralis Major';
                case 'conb'
                    f_name = 'Conventional Baseline';
                case 'cont'
                    f_name = 'Conventional Therapy';
                case 'robb'
                    f_name = 'Teach/BridgeT Baseline';
                case 'robt'
                    f_name = 'Teach Therapy';
                case 'bri'
                    f_name = 'BridgeT';
                otherwise
                    msgID = 'getFullName:invalidName';
                    msgTxt = [s_name, ' is not registered'];
                    throw(MException(msgID,msgTxt))
                        
            end
        end