%display value
disp('Value entered: ')


%reset port everytime the program starts to avoid error
delete(instrfind({'Port'},{'COM6'}));

%Port number, baud communication, 9600 standard rate
s1 = serial('COM6', 'BAUD', 9600);

%open the port
fopen(s1);
%infintely run
while(1)
%pause required to fully receive the value
pause(1.45);
%prompt
servalue= input('Enter 1 for yellow, 2 for green, 3 for red, and 4 for blue:');
fprintf(s1, servalue)
end

%close the port
fclose(s1);
%once closed, prompt the user
disp('CLOSED')
disp(s1)