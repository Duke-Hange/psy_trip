%% 0.05hz补mark
clear
filenm='C:\Users\luping\Desktop\剂量实验\000_yuhang.snirf';

markfile=SnirfClass('C:\Users\luping\Desktop\剂量实验\000_yuhang.snirf');     


mark_rest1=markfile.stim(1,1).states;
mark_rest2=markfile.stim(1,3).states;
time=markfile.data.time;

for i=1:15
    %%补入rest1的mark
    [row1,~,~] = find(time==mark_rest1(1,1));
    row1=row1+(i-1)*220;
    mark_rest1(i,1)= time(row1,1);
    mark_rest1(i,2)=1;
    
    %%补入rest2的mark
    [row2,~,~] = find(time==mark_rest2(1,1)) ;
    row2=row2+(i-1)*220;
    mark_rest2(i,1)= time(row2,1);
    mark_rest2(i,2)=1;
end

markfile.stim(1,1).states=mark_rest1;
markfile.stim(1,3).states=mark_rest2;
markfile;

markfile.Save('C:\Users\luping\Desktop\剂量实验\000_yuhang_with_mark.snirf');

markfile=SnirfClass('C:\Users\luping\Desktop\剂量实验\000_yuhang_with_mark.snirf');  
mark_rest1=markfile.stim(1,1).states;
mark_rest2=markfile.stim(1,3).states;



%% 0.02hz补mark
clear
markfile=SnirfClass('C:\Users\luping\Desktop\剂量实验\000_yuhang.snirf');     
mark_rest1=markfile.stim(1,1).states;
mark_rest2=markfile.stim(1,3).states;
time=markfile.data.time;

for i=1:6
    %%补入rest1的mark
    [row1,col,v] = find(time==mark_rest1(1,1))
    row1=row1+(i-1)*550
    mark_rest1(i,1)= time(row1,1)
    mark_rest1(i,2)=1
    
    %%补入rest2的mark
    [row2,col,v] = find(time==mark_rest2(1,1)) ;
    row2=row2+(i-1)*550
    mark_rest2(i,1)= time(row2,1)
    mark_rest2(i,2)=1
end