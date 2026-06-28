## FigS
FigS 是一款面向 MATLAB `.fig` 图像的可视化美化与导出工具，主要用于对多组 Fig 图进行统一风格设置、快速排版调整和高质量图片导出。软件提供图形界面，支持预设风格、用户模板、配色方案、坐标轴与字体调整、图例处理以及多格式图片导出，适用于论文绘图、学位论文插图和科研汇报图像整理等场景。
<p align="center">
  <img width="60%" alt="image" src="https://github.com/user-attachments/assets/f284f329-2957-4f5f-84d6-91a11356b0a1" />
  <img width="60%" alt="image" src="https://github.com/user-attachments/assets/82105eaf-88d3-48e0-91d1-95cf42cfc590" />
  <img width="60%" alt="image" src="https://github.com/user-attachments/assets/681c967c-05db-4fa6-9a50-1a92a1d66ce8" />
</p>

## 主要功能

* **一键美化 Fig 图**：快速应用预设风格或用户自定义模板。
* **多种配色方案**：内置多套颜色模板，便于统一论文图件风格。
* **图像细节调整**：支持坐标轴、网格、标签、字体、图例、线条、标记点等常用图形元素调整。
* **视图与画布控制**：支持 XY、XZ、YZ、3D、透视、比例和画布比例等视图设置。
* **高质量图片导出**：支持 PNG、JPG、TIFF、EPS、PDF、EMF 等格式导出，并可设置分辨率和保存路径。
* **自定义扩展**：可通过模板文件添加个人绘图风格、常用函数和配色方案。

## 文件结构

```text
FigS/
├── FigS.p                  # 软件主程序
├── Example.m               # 示例脚本
├── fb_apply.p              # 样式应用模块
├── fb_bar.p                # 柱状图处理模块
├── fb_boxplot.p            # 箱线图处理模块
├── fb_color.p              # 颜色处理模块
├── fb_errorbar.p           # 误差棒处理模块
├── fb_export.p             # 图片导出模块
├── fb_font.p               # 字体处理模块
├── fb_hist.p               # 直方图处理模块
├── fb_inset.p              # 局部放大图处理模块
├── fb_line.p               # 折线图处理模块
├── fb_presets.p            # 预设风格模块
├── fb_scatter.p            # 散点图处理模块
├── fb_stem.p               # 离散序列图处理模块
├── fb_surface.p            # 曲面图处理模块
├── fb_util.m               # 工具函数
└── templates/
    ├── color_schemes.m     # 色彩模板
    ├── common_functions.m  # 常用函数
    ├── preset_styles.m     # 预设风格
    └── user_styles.m       # 用户模板
```

## 安装方法

1. 打开 MATLAB。
2. 在 MATLAB 顶部菜单栏中选择：
主页 → 设置路径
<img width="60%" alt="image" src="https://github.com/user-attachments/assets/b3ce7847-bb4d-4e18-a2b4-fa9bca9a4b7d" />

3. 在弹出的“设置路径”窗口中，点击：
添加并包含子文件夹...
<img width="60%" alt="image" src="https://github.com/user-attachments/assets/2f079cbd-31ef-4c65-9173-2707bd845131" />

4. 选择 FigS 所在文件夹。
  <img width="60%" alt="image" src="https://github.com/user-attachments/assets/700362dd-00a6-43cb-8dde-ed330602fa1f" />
  
6. 点击“保存”，完成路径添加。

完成上述步骤后，MATLAB 即可识别 FigS 主程序及其相关函数文件。

## 启动方法

在 MATLAB 命令行窗口中输入：FigS

<img width="60%" alt="image" src="https://github.com/user-attachments/assets/ae73a6bc-a699-466d-9ccc-7527e2b95f5f" />

运行后将打开 FigS 图形界面，即 Plot Style Studio。

## 基本使用流程

1. 在 MATLAB 中打开或生成需要处理的 `.fig` 图像。
2. 在命令行输入 `FigS` 启动软件。
3. 在“样式”页面选择预设风格、用户模板或配色方案。
4. 在“调整”页面修改坐标轴、标签、字体、图例、网格、画布比例等图形属性。
5. 在“导出”页面选择图片格式、分辨率、保存路径和文件名。
6. 点击“导出图片”，完成图像导出。

## 界面说明

### 1. 样式页面

样式页面主要用于快速应用图像风格，包含以下功能：

* 应用预设风格；
* 应用用户模板；
* 启用配色方案；
* 调用常用绘图函数；
* 刷新模板和函数列表。

该页面适合对多张 Fig 图进行统一格式处理。

### 2. 调整页面

调整页面主要用于图像细节修改，包含以下功能：

* 视图切换：XY、XZ、YZ、3D、透视等；
* 默认标签设置：X 轴标签、Y 轴标签、Z 轴标签和图标题；
* 字体与解释器设置：TeX、LaTeX、中英文字体、字号等；
* 数据对象调整：线宽、标记大小、添加标记、清除标记等；
* 坐标轴与背景设置：网格、刻度、坐标轴范围、透明背景、白底黑线等。

### 3. 导出页面

导出页面用于将当前 Fig 图导出为图片文件，支持以下格式：PNG、JPG、TIFF、EPS、PDF、EMF


可设置导出分辨率，例如：300 DPI、600 DPI、900 DPI、1200 DPI


同时可自定义保存路径和文件名。

## 自定义功能

FigS 支持用户通过 `templates` 文件夹中的 MATLAB 文件进行功能扩展。

### `color_schemes.m`

用于定义色彩模板。用户可以在该文件中添加新的颜色组合，用于统一图像配色。

### `common_functions.m`

用于定义常用函数。适合放置经常使用的图像处理、格式调整或辅助绘图函数。

### `preset_styles.m`

用于定义预设风格。用户可以在其中设置适合论文、汇报或期刊投稿的统一图形格式。

### `user_styles.m`

用于定义用户模板。适合保存个人常用的图像美化方案，例如学位论文风格、SCI 论文风格或课题组统一图形模板。


## 适用场景

* MATLAB 科研绘图美化；
* 多组 `.fig` 图统一排版；
* 学位论文图件格式整理；
* SCI 论文投稿图片导出；
* 课题组图像风格统一；
* 汇报 PPT 图像快速优化。

## 注意事项

* 建议在批量修改图像前备份原始 `.fig` 文件。
* 导出前请确认当前图像窗口为需要处理的目标图像。
* 若需要长期复用某种图像格式，建议将其写入 `user_styles.m` 或 `preset_styles.m`。
* 修改模板文件后，如界面未自动更新，可点击“刷新列表”或重新启动 FigS。

## 使用示例 

在 MATLAB 中绘制一张图：

```matlab
fprintf('[1/7] fb_line - 增强折线图\n');
figure('Name', 'fb_line 示例');
x = linspace(0, 2*pi, 100);
fb_line(x, sin(x), 'DisplayName', 'sin(x)');
fb_line(x, cos(x), 'DisplayName', 'cos(x)');
fb_line(x, sin(2*x), '--', 'DisplayName', 'sin(2x)');
legend('Location', 'best');
title('增强折线图 - fb\_line');
xlabel('x'); ylabel('y');
```
<img width="40%" alt="image" src="https://github.com/user-attachments/assets/b7791bd7-0da5-44f0-926f-001d3dcb2531" />

随后在命令行输入：FigS

**通用模板**：

<img width="40%" alt="image" src="https://github.com/user-attachments/assets/eef3a37a-2c3a-43a6-bbcc-4e340e5ae0d9" />


**细线简约**：

<img width="40%" alt="image" src="https://github.com/user-attachments/assets/9531021e-2992-4762-8bf9-122dab15d981" />

**细线全框**：

<img width="40%" alt="image" src="https://github.com/user-attachments/assets/8dbc99f8-0e3d-4c72-8509-e56fdd096fa8" />

**粗线全框**：

<img width="40%" alt="image" src="https://github.com/user-attachments/assets/2d40dd66-e070-455f-aee0-61a7ad508d07" />

**中英文字体（中文宋体；英文新罗马）**：

<img width="40%" alt="image" src="https://github.com/user-attachments/assets/e27c7af7-18d0-4974-a357-603891d1bc85" />

**局部放大**：

<img width="40%" alt="image" src="https://github.com/user-attachments/assets/0f44110d-0893-4d90-98f7-9b9431ba0691" />

**Line_虚线**：

<img width="40%" alt="image" src="https://github.com/user-attachments/assets/1f5d2b9f-5c39-4bd8-9132-873cea1ec0fd" />

**Line_标记**：

<img width="40%" alt="image" src="https://github.com/user-attachments/assets/2d09428b-0500-4ee6-82b6-8423b988a514" />

**如果标记点太多，在“调整”->“数据对象”->“添加标记”（需要手动改变不同线标记样式）**：

<img width="40%" alt="image" src="https://github.com/user-attachments/assets/fd405834-fb9f-425e-8a5e-e2b0834cd1bb" />

**临时渐变色：对于imagesc函数无法使用颜色模板，需要在常用函数“临时渐变色”进行操作**
**原图**：

<img width="40%" alt="image" src="https://github.com/user-attachments/assets/f076c71e-0522-45e8-989b-0c155b40db32" />

**设置**：

<img width="40%" alt="image" src="https://github.com/user-attachments/assets/40712fe7-26ff-4240-9582-cda37a1bbfd0" />

**美化**：

<img width="40%" alt="image" src="https://github.com/user-attachments/assets/d5b14c25-62f1-4fdd-9954-2bb4c03911a5" />

**如果是对线条进行美化，渐变数量n选择对应的线条数量**







