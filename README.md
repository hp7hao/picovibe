# PICOVIBE

这是一个PICO-8的爱好者项目，为了方便国内爱好者相互交流，方便游戏分享，本项目致力于以下目标。

* 提供一些简单的工具以及类库
* 收集国内PICO-8爱好者开发的游戏作品

# 项目版权说明

本项目包含多个pico-8子项目，每个子项目的版权属于其署名的作者。
请确保在使用或分发这些项目时遵守相应的版权协议。

## 卡带
| 标题 | 图片 | 状态 |
|------|------|------|
| i18ndemo<br/>多语言示例（中文） | ![i18ndemo](./carts/pico8pixelbomb/i18ndemo/release/i18ndemo.zhcn.p8.png) | - |
| nezhapoems<br/>《小爷集》要求全文背诵 | ![nezhapoems](./carts/pico8pixelbomb/nezhapoems/nezhapoems.zhcn.p8.png) | 开发中 |
| pico8go-about<br/>pico8go 关于(掌机) | ![pico8go-systeminfo](./carts/pico8pixelbomb/pico8go-about/release/pico8go-about.zhcn.p8.png) | - |
| pico8go-thanks<br/>pico8go 致谢(掌机) | ![pico8go-thanks](./carts/pico8pixelbomb/pico8go-thanks/release/pico8go-thanks.zhcn.p8.png) | - |
| pico8go-wizard<br/>pico8go 致谢(掌机) | ![pico8go-wizard](./carts/pico8pixelbomb/pico8go-wizard/release/pico8go-wizard.zhcn.p8.png) | - |
| splooshdemo | ![splooshdemo](./carts/pico8pixelbomb/splooshdemo/splooshdemo.p8.png) | - |
| yxkl<br/>元宵节快乐 | ![yxkl](./carts/pico8pixelbomb/yxkl/yxkl.p8.png) | - |
| bas-pico8gomod<br/>pico8go《小鸡蹦蹦跳》中文+振动| ![bas-pico8gomod](./carts/pico8pixelbomb/bas-pico8gomod/release/basmodcn.zhcn.p8.png) | - |
| celeste-pico8gomod<br/>pico8go《蔚蓝经典版》中文+振动+PC音源| ![celeste-pico8gomod](./carts/pico8pixelbomb/celeste-pico8gomod/release/celestemodcn.zhcn.p8.png) | - |
| justoneboss-pico8gomod<br/>pico8go《只此一敌》振动支持| ![justoneboss-pico8gomod](./carts/pico8pixelbomb/justoneboss-pico8gomod/release/justonebossmodcn.zhcn.p8.png) | - |
| pet-the-cat-pico8gomod<br/>pico8go《撸猫》中文+振动 | ![pet-the-cat-pico8gomod](./carts/pico8pixelbomb/pet-the-cat-pico8gomod/release/pet-the-cat.zhcn.p8.png) | - |

## 卡带模板
| 标题 | 图片 | 作者 |
|------|------|------|
| e-zombie | ![e-zombie](./tools/resources/imgs/cart_templates/e-zombie.png) | 压缩文渐 |
| e-zombie16 | ![e-zombie16](./tools/resources/imgs/cart_templates/e-zombie16.png) | 压缩文渐 |

## 其它
| 标题 | 说明 |
|------|------|
| pico8 中文手册 | [pico8manual](./docs/pico8manual/pico8手册v0.2.6c_rev1.pdf) |

# 编译工具

## 初始化

下载所有依赖
```cmd
git submodule update --init --recursive
```

## 使用方法

Windows系统，打开命令行，在项目目录运行下面的命令进行编译（脚本通过LLM翻译自build_pico8cart.sh，还未测试）
```cmd
build_pico8cart.bat --cart carts/pico8pixelbomb/bas-pico8gomod/basmodcn.p8
```

如果你使用的是linux系统，通过下面的命令来编译卡带
```bash
./build_pico8cart.sh --cart carts/pico8pixelbomb/bas-pico8gomod/basmodcn.p8
```

参数说明：
- `--cart`: 要编译的PICO-8游戏文件路径（.p8文件）

脚本会自动：
1. 检测并构建所有配置的语言版本
2. 生成对应的翻译文件
3. 使用PICO-8导出卡带图片
4. 应用指定的卡带模板
5. 生成最终的多语言卡带文件

所有生成的文件将保存在 `release` 目录下。

# 工具说明

[pico8i18n](./tools/pico8i18n/README.md)

[img2p8](./tools/img2p8/README.md)


# 致谢

#### deps/picotool
	https://github.com/dansanderson/picotool.git

#### tools/customcart/main.c
	https://github.com/usrshare/pico8-customcart.git

#### carts/pico8pixelbomb/pico8go-thanks
	SPRWAR.p8 by randc0degen


# PICO-8 像素炸弹！

企鹅交流群：143554779