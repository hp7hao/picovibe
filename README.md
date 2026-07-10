# PICOVIBE

这是一个PICO-8的爱好者项目，为了方便国内爱好者相互交流，方便游戏分享，本项目致力于以下目标。

* 收集国内PICO-8爱好者开发的游戏作品

> **设备 API（震动 / 成就）**：所有 mod 卡带统一使用 PICO8GO 的 `p8go.*` IPC（`p8go.vibe(ms, strength)`、`p8go.vibe_stop()`、`p8go.ach_unlock(id)` 等）。运行时源码与契约由 `projects/xwsdk` 维护，pico8ide 自动注入；详情见 [`docs/specs/picovibe_spec.md`](./docs/specs/picovibe_spec.md)。旧的 `printh "vibrator"` / `"pico8goapi"` 通道已废弃，不要在新卡带中再使用。

# 项目版权说明

本项目包含多个pico-8子项目，每个子项目的版权属于其署名的作者。
请确保在使用或分发这些项目时遵守相应的版权协议。

## 卡带
| 标题 | 源文件 | 状态 |
|------|--------|------|
| i18ndemo<br/>多语言示例（中文） | [i18ndemo.p8mod](./carts/pico8pixelbomb/i18ndemo/i18ndemo.p8mod) | - |
| nezhapoems<br/>《小爷集》要求全文背诵 | [nezhapoems.p8mod](./carts/pico8pixelbomb/nezhapoems/nezhapoems.p8mod) | 开发中 |
| pico8go-about<br/>pico8go 关于(掌机) | [pico8go-about.p8.png](./carts/pico8go/pico8go-about/pico8go-about.p8.png) | - |
| firework-simulators<br/>烟花模拟器 | [firework-simulators.p8mod](./carts/pico8go/firework-simulators/firework-simulators.p8mod) | 源码卡带 |
| pico8go-thanks<br/>pico8go 致谢(掌机) | [pico8go-thanks.p8.png](./carts/pico8go/pico8go-thanks/pico8go-thanks.p8.png) | - |
| pico8go-wizard<br/>pico8go 致谢(掌机) | [pico8go-wizard.p8.png](./carts/pico8go/pico8go-wizard/pico8go-wizard.p8.png) | - |
| splooshdemo | [splooshdemo.p8mod](./carts/pico8pixelbomb/splooshdemo/splooshdemo.p8mod) | - |
| yxkl<br/>元宵节快乐 | [yxkl.p8mod](./carts/pico8pixelbomb/yxkl/yxkl.p8mod) | - |
| bas-pico8gomod<br/>pico8go《小鸡蹦蹦跳》中文+振动| [basmod.p8mod](./carts/pico8pixelbomb/bas-pico8gomod/basmod.p8mod) | - |
| celeste-pico8gomod<br/>pico8go《蔚蓝经典版》中文+振动+PC音源| [celestemod.p8mod](./carts/pico8pixelbomb/celeste-pico8gomod/celestemod.p8mod) | - |
| justoneboss-pico8gomod<br/>pico8go《只此一敌》振动支持| [justonebossmod.p8mod](./carts/pico8pixelbomb/justoneboss-pico8gomod/justonebossmod.p8mod) | - |
| pet-the-cat-pico8gomod<br/>pico8go《撸猫》中文+振动 | [pet-the-cat.p8mod](./carts/pico8pixelbomb/pet-the-cat-pico8gomod/pet-the-cat.p8mod) | - |

## 其它
| 标题 | 说明 |
|------|------|
| pico8 中文手册 | [pico8manual](./docs/pico8manual/pico8手册v0.2.6c_rev1.pdf) |

# 构建说明

`.p8mod` / `.p8` 到 `.p8.png` 的发布导出由 `pico8ide` CLI / headless exporter 负责。本仓库不再维护本地转换脚本、Python 虚拟环境、`picotool` / `shrinko8` 子模块或自定义卡带图片工具。

```bash
scripts/export-p8mod.sh carts/pico8pixelbomb/i18ndemo/i18ndemo.p8mod
```

脚本会通过相对路径调用相邻仓库的 `../pico8ide/out/extension/p8modtool.js`，并在卡带目录的 `release/` 下生成同名 `.p8` 和 `.p8.png`。


# 致谢

#### carts/pico8pixelbomb/pico8go-thanks
	SPRWAR.p8 by randc0degen


# PICO-8 像素炸弹！

企鹅交流群：143554779
