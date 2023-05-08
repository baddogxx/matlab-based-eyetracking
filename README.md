# matlab-based-eyetracking

## 介绍
这是一个基于`matlab`的简单实时眼动追踪项目，我将其作为大二matlab课程设计和大三的数字图像处理大作业。为此我还用`matlab app`做了一个图形界面。整体硬件要求为`matlab`运行环境和一个usb摄像头。

利用`matlab`中图像处理工具箱和图像采集工具箱对usb摄像头拍摄到的近眼图像处理后得到眼球中心点坐标，在图像中标记并输出坐标值。
___
##  算法原理
算法流程分为图像采集、预处理、阈值分割、形态学处理、保留最大连通区域、位置标记五个部分。使用到的图像处理技术有图像灰度转化、最大类间方差法阈值分割、形态学处理等。  
初始眼部图像由pc调用摄像头拍照获取，采集到的图像经过预处理为一张灰度眼部图像。使用最大类间方差法对灰度图像进行阈值分割，可以得到去除眼部皮肤特征的图像。下一步先对图像进行先闭后开运算分割出瞳孔及虹膜区域。对形态学处理后的图像求最大连通区域并保留，去除残留的小块噪点区域，保留瞳孔与虹膜区域。最后使用`regionprops`函数获取瞳孔中心点坐标并用标记函数标记中心点。
___
## 文件介绍
- `EyeTracking_main.m` 这是一个简单的实时眼动追踪项目，图像处理算法运行在一个for循环内，程序初始只处理200帧图像后结束运行。
- `EyeTracking.mlapp`  这是使用`matlab app`做的图形化界面，界面图片请打开panel.png查看内部算法和`EyeTracking_main.m`大同小异。添加了手动结束按钮。
- `Img_Tag.m` 和 `Cam_Img_Tag.m` 这两个是我写的标记函数，用来标记瞳孔位置和眼球中心点坐标。


___
## 注意
- `matlab`中需要另外安装图像采集工具箱（`imag acquisition toolbox  support package for os generic video interface`）.
- 项目目前准确度不太理想，对光线要求高.
- `EyeTracking_main.m`运行时必须让程序自动跑完（程序自动关闭摄像头），若摄像头没有正常关闭，下一次开启时会报错（这时重新打开`matlab`就能解决）。

