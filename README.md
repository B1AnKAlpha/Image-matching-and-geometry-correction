# 遥感原理与应用实验项目

![MATLAB](https://img.shields.io/badge/MATLAB-R2016b+-blue.svg) ![Language](https://img.shields.io/badge/Language-中文-red.svg) ![License](https://img.shields.io/badge/License-Educational-green.svg) ![Status](https://img.shields.io/badge/Status-Complete-success.svg)

遥感原理与应用课程实验代码，包含图像配准、几何校正和图像融合等算法实现。

## 项目简介

本项目使用 MATLAB 实现了遥感图像处理的核心算法：
- NGC 图像匹配
- 多项式几何校正
- 双线性插值重采样
- 多光谱与全色影像融合

## 目录结构

```
.
├── 实验一/
│   ├── match3.m          # NGC 图像匹配
│   ├── match4_1.m        # 多项式几何校正
│   ├── match4_2.m        # 双线性插值
│   ├── 参考影像.tif
│   └── 待配准.tif
│
└── 实验二/
    ├── merge.m           # 图像融合
    ├── 多光谱.tif
    └── 全色.tif
```

## 实验内容

### 实验一：图像配准与几何校正

实现基于控制点的图像配准流程：
1. NGC 匹配算法自动提取同名点
2. 多项式变换建立几何校正模型
3. 双线性插值完成图像重采样

### 实验二：多光谱与全色影像融合

将低分辨率多光谱影像与高分辨率全色影像融合，获得高分辨率多光谱影像。

## 使用方法

### 环境要求
- MATLAB R2016b 或更高版本
- Image Processing Toolbox

### 运行示例

```matlab
% 图像配准
cd 实验一
match3        % NGC 匹配
match4_1      % 几何校正
match4_2      % 重采样

% 图像融合
cd 实验二
merge         % 影像融合
```

## 技术说明

**NGC（归一化互相关）匹配**  
基于统计相关性的图像匹配方法，用于自动提取同名点。

**多项式几何校正**  
利用控制点建立多项式变换模型，实现图像几何纠正。

**双线性插值**  
图像重采样方法，保证校正后影像的质量。


## 许可

本项目仅用于教学和学习目的。

