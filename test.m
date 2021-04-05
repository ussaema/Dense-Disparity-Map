classdef test < matlab.unittest.TestCase
    % to start : runtests('test')
    
    %Test your challenge solution here using matlab unit tests
    %
    % Check if your main file 'challenge.m', 'disparity_map.m' and 
    % verify_dmap.m do not use any toolboxes.
    %
    % Check if all your required variables are set after executing 
    % the file 'challenge.m'
    
    properties
    end
     
     methods (Test)
        function toolbox_test(testCase)
            testCase.verifyFalse(check_toolboxes('challenge.m'));
            testCase.verifyFalse(check_toolboxes('disparity_map.m'));
            testCase.verifyFalse(check_toolboxes('verify_dmap.m'));
        end
        function variables_test(testCase)
            load('challenge.mat');%Call the function containing the variables to be tested
            
            testCase.verifyNotEmpty(members);
            testCase.verifyNotEmpty(mail);
            testCase.verifyNotEmpty(group_number);
           testCase.verifyNotEqual(elapsed_time,0);
           testCase.verifyNotEqual(D,0);
           testCase.verifyNotEqual(R,0);
           testCase.verifyNotEqual(T,0);
           testCase.verifyNotEqual(p,0);  
        end
        
        function psnr_test(testCase)   
            load('challenge.mat');
            treshold=0.02;
       
            testCase.verifyLessThan(psnr(double(D),G)-p,treshold);            
          
        end
     end   
end

function toolboxes = check_toolboxes(file)
    [~,pList]=matlab.codetools.requiredFilesAndProducts(file);
    if (size({pList.Name}',1)~=1) % (MATLAB always listed)
        toolboxes=true;
    else
        toolboxes=false;
    end
end 

