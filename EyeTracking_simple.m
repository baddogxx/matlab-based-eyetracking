
close all;
clear all;
 row = videoinput('winvideo',1,'MJPG_640x480');            %调用摄像头，设置分辨率为640*480 row为摄像头拍摄图像 摄像头名称为winvideo 1
          triggerconfig(row,'manual');
          start(row);
%           app.camera_flag=1;                                        %摄像头打开标志为真
          %进入图像处理循环
          for i=1:200                 
                  a=getsnapshot(row);                               %得到摄像头的一帧
                %预处理
                  a=im2double(a);
                  b=rgb2gray(a);                                    %将a转换为灰度图像b
                %阈值分割  
                  T=graythresh(b);                                  %使用最大类间方差法求阈值T
                  c=imbinarize(b,T-0.17);                           %以T-0.17为阈值将b二值化为c
                %形态学处理 
                  pa=strel('disk',25);                              %Pa为半径为25的圆盘结构元素
                  d=imclose(c,pa);                                  %使用Pa结构元素对c执行闭运算
                  pb=strel('disk',50);                              %Pb为半径为50的圆盘结构元素
                  bw=imopen(d,pb);                                  %使用Pb结构元素对d执行开运算
                  bw=~bw;                                           %图像取反
                %求最大连通区域并保留         
                  imLabel = bwlabel(bw);                            %对各连通域进行标记
                  stats = regionprops(imLabel,'Area');              %求各连通域的大小
                  area = cat(1,stats.Area);                         %将括号里的三个量合在一起
                  index = find(area == max(area));                  %求最大连通域的索引
                  img = ismember(imLabel,index);                    %img为索引转化来的rgb图像
                %位置标记
                  box=regionprops(img,'BoundingBox');               %img为图像处理完成后的图像
                  x=box.BoundingBox(1);                             %最小外接矩形的起始点横坐标
                  y=box.BoundingBox(2);                             %最小外接矩形的起始点纵坐标
                  w=box.BoundingBox(3);                             %最小外接矩形的长
                  h=box.BoundingBox(4);                             %最小外接矩形的宽
                %取整
                  x=fix(x);
                  y=fix(y);
                  w=fix(w);
                  h=fix(h);
                %使用标记函数标记 
                  img_done=Cam_Img_Tag (b,y,x,w,h);  
                  imshow(img_done);             %显示         
          end
          disp([num2str(i)]);%输出i的值
          delete(row);%关闭摄像头
         