
close all;
clear all;
row= videoinput('winvideo',1,'MJPG_640x480');%调用摄像头，设置
%分辨率为640*480 row为摄像头拍摄图像 摄像头名称为winvideo 1
 triggerconfig(row,'manual');%设置摄像头触发模式为手动模式，在
 %循环中保持摄像头常开，大幅减少程序运行时间
start(row);%打开摄像头

   papa=17;%元素算子papa初始值为17
   pbpb=40;%元素算子papa初始值为40
   s=100;
   z=0.5;

for i=1:200 
    a=getsnapshot(row);%得到摄像头的一帧
    b=rgb2gray(a);%将a转换为灰度图像b
    T=graythresh(b);%使用最大类间方差法求阈值T
    c=imbinarize(b,T-0.17);%以T-0.17为阈值将b二值化为c
%形态学处理
    pa=strel('disk',papa);%Pa为半径为25的圆盘结构元素，算子papa在
    %下面循环中将进行算子的自适应调节
    d=imclose(c,pa);%使用Pa结构元素对c执行闭运算
    pb=strel('disk',pbpb);%Pb为半径为50的圆盘结构元素
    bw=imopen(d,pb);%使用Pb结构元素对d执行开运算
    bw=~bw;%图像取反
%求最大连通区域并保留 
   %在下面的算子自适应调节中将用到此步骤
    imLabel = bwlabel(bw);%对各连通域进行标记
    stats = regionprops(imLabel,'Area');%求各连通域的大小
    area = cat(1,stats.Area);%将括号里的三个量合在一起
    index = find(area == max(area));%求最大连通域的索引
    img = ismember(imLabel,index);%img为索引转化来的rgb图像
%判断img是否全白（在进行图像闭运算时由于算子太大有时会导致其将
%阈值分割得到的图像完全处理，img全白则下面进行提取box.BoundingBox
%矩阵时会出现多个值而报错）   
if img==0
    %imshow(b);
    disp('error');
else
 %对图像d求最大连通区域并保留
    k1= bwlabel(d);
    stats1 = regionprops(k1,'Area');
    area1 = cat(1,stats1.Area);
    index1 = find(area1 == max(area1));
    d1= ismember(k1,index1);  
 %求闭运算后前后两帧图像的似圆度   
    k=regionprops(d1,'BoundingBox');%利用regionprops函数求图像k的
    %相关参数
    w1=k.BoundingBox(3);%w1为图像最小外接矩形的一条边
    h1=k.BoundingBox(4);%h1为图像最小外接矩形的另一条边
    s1=w1-h1;%两条边做差得到s1，s1的值越接近0则图像k越接近圆形，也就
    %意味着闭运算能够去除睫毛 眉毛 等，留下瞳孔
    
%将s1与上一帧的s1进行比较，若变小则代表图像的近圆度变高，即此时算子
%papa有效应加强，反之将减弱之

    if s1<=s;
    papa=papa+1;
    s=s1;
    end
    if s1>=s||d==0;
        %有时会出现算子太强导致闭运算完成后图像一片空白使
        %下一个循环中提取变量报错，所以加入d==0这个条件
    papa=papa-1;
    
    if papa<=0
        papa=1;%防止算子出现负值
    end
    s=s1;
    end
 %算子pbpb的时间自适应调节
    k1=regionprops(bw,'Area');
    z1=k1.Area;
    if z1>=z
        pbpb=pbpb+1;
        z=z1;
    else
        pbpb=pbpb-1
        z=z1;
    end
    
%求img的最小外接矩形的起始点与长宽
    box=regionprops(img,'BoundingBox');%img为图像处理完成后的图像
    x=box.BoundingBox(1);%最小外接矩形的起始点横坐标
    y=box.BoundingBox(2);%最小外接矩形的起始点纵坐标
    w=box.BoundingBox(3);%最小外接矩形的长
    h=box.BoundingBox(4);%最小外接矩形的宽
  
    %作图
    
      subplot(221);
      imshow(c);
      title('阈值分割后');
      subplot(222);
      imshow(bw);
      title('形态学处理后');
      subplot(223);
      imshow(img);
      title('保留最大连通区域');
      subplot(224);
      imshow(b);
      title('显示灰度图像并标记');
      hold on;%保持图像b
      plot(x+w/2,y+h/2,'g+')%标记出中心点
    hold off
    rectangle('position', [x,y,w,h],'EdgeColor', 'g');%利用函数
    %rectangle画出瞳孔的外接矩形
   
end  
    pause(0.0001);%暂停一个极小的时间以显示外接矩形
    disp([num2str(i)]);%输出i的值
    
    
end
delete(row);%关闭摄像头
