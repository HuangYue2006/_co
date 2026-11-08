# 第八週：IC 設計的 EDA 是什麼？

## 1. 定義

**EDA（Electronic Design Automation，電子設計自動化）** 是用電腦軟體來協助設計、驗證與製造積體電路（IC）的一整套工具。

現代晶片動輒有數十億顆電晶體，不可能用手一顆一顆畫。EDA 讓工程師可以像寫程式一樣用 **硬體描述語言（HDL）** 描述電路，再由工具自動完成「模擬 → 合成 → 擺放 → 繞線 → 驗證」，最後產出可以交給晶圓廠製造的 **GDSII 光罩檔**。

可以把它類比成軟體的編譯器工具鏈：

| 軟體 | 硬體（EDA） |
|------|------------|
| 原始碼（C / Jack） | HDL（Verilog / VHDL / Veryl / nand2tetris HDL） |
| 編譯器 | 邏輯合成（Logic Synthesis） |
| 組譯、連結 | 擺放與繞線（Place & Route） |
| 單元測試 | 模擬（Simulation）＋ 測試腳本 |
| 執行檔 | GDSII（光罩）或 FPGA bitstream |

## 2. IC 設計流程與各階段的 EDA 工具

```
規格 → RTL (HDL) → 模擬驗證 → 邏輯合成 → 標準元件映射 → 擺放 → 時脈樹 / 繞線 → 時序分析 (STA) → 功耗 / IR Drop → DRC/LVS → GDSII → 晶圓廠
        ╰──────── 前端 Front-End ────────╯   ╰─────────────── 後端 Back-End ───────────────╯
```

| 階段 | 做什麼 | 對應到本課 |
|------|-------|-----------|
| RTL 設計 | 用 HDL 描述電路行為 / 結構 | 我寫的 `And.hdl` … `CPU.hdl` |
| 模擬（Simulation） | 給輸入、看輸出是否符合預期 | nand2tetris HardwareSimulator 跑 `.tst`，和 `.cmp` 比對產生 `.out` |
| 邏輯合成（Synthesis） | 把 HDL 轉成由基本閘組成的 netlist，並做最佳化 | 我們手動把 Mux 拆成 And/Or/Not、最後全部變成 Nand |
| 技術映射（Tech Mapping） | 把通用閘對應到製程廠提供的「標準元件庫」 | Nand 就像是唯一的標準元件 |
| 擺放（Placement） | 決定每個元件在晶片上的位置 | — |
| 繞線（Routing） | 用金屬線把元件接起來 | — |
| 靜態時序分析（STA） | 檢查最長路徑延遲是否小於時脈週期 | 例：`Add16` 的進位要經過 16 個 FullAdder，是關鍵路徑 |
| 實體驗證（DRC / LVS） | 檢查佈局是否符合製程規則、和電路圖一致 | — |
| 產出 GDSII | 交給晶圓廠（Tape-out） | — |

## 3. 使用的 EDA 軟體與心得

### 3.1 nand2tetris Hardware Simulator（本學期作業用的）

本學期第 1～5 章的所有晶片，我都用 nand2tetris 的 **HardwareSimulator** 跑官方測試：

* 每顆晶片的 `.tst` 是測試腳本，`.cmp` 是正確答案，模擬器會產生 `.out` 並逐列比對。
* 例如 `CPU.tst` 會一個 clock 一個 clock 檢查 `outM`、`writeM`、`addressM`、`pc`，只要有一個位元錯就會停下來並指出哪一列不同。
* `Computer` 要能跑 `Add.hack`、`Max.hack`、`Rect.hack` 三個機器碼程式，等於是在模擬器上驗證「整台電腦」。

這其實就是業界 EDA 流程中「RTL 模擬驗證」的簡化版：**先寫測試、再寫電路、用工具自動比對**。

### 3.2 線上 Hack HDL 模擬器（[hack-computer](https://github.com/ccc-js/hack-computer)）

老師的 [線上版](https://ccc-js.github.io/hack-computer/dist/hdl.html) 可以直接在瀏覽器執行 nand2tetris 的 HDL 和 `.tst`，不用安裝 Java。除了模擬外，還可以：

* **檢視電路圖**：把晶片一路展開到 Nand / DFF。
* **「合成 LUT」**：示範一個迷你 EDA 流程，從 RTL → 邏輯 netlist → 與技術無關的最佳化 → 技術映射 → 擺放 → 繞線 → STA，分 FPGA 和 ASIC 兩種後端。

這讓我看到：我們寫的 nand2tetris HDL，接上這些步驟之後，就和真正的晶片設計流程接起來了。

### 3.3 veryl2chip（[ccc-eda/veryl2chip](https://github.com/ccc-eda/veryl2chip/)）

veryl2chip 是用 Rust 寫的完整開源 EDA，可以在 [網頁 IDE](https://ccc-eda.github.io/veryl2chip/web/dist/index.html) 中直接使用：

* 輸入語言是 **Veryl**（一種新的 HDL），先做語法檢查與 RTL / 閘級模擬。
* **FPGA 流程**：合成後產生 iCE40UP5K 的 bitstream，可以在「虛擬 iCEBreaker 開發板」上看結果。
* **ASIC 流程**：標準元件映射 → 列擺放（Row Placement）→ 時脈樹與全域繞線 → 細部繞線 → 時序分析（STA）→ 功耗與 IR Drop，並使用 SkyWater 開源的 **SKY130** 製程元件庫，最後可以下載 **GDS** 檔。

也就是說，一個學生在瀏覽器裡就能走完「從 HDL 到晶片佈局」的完整流程，這在以前需要非常昂貴的商用軟體授權。

### 3.4 商用工具與課程

業界主要的 EDA 公司是 **Synopsys**、**Cadence**、**Siemens EDA（原 Mentor）**。
例如康乃爾大學 [ECE 5745 Complex Digital ASIC Design](https://www.csl.cornell.edu/courses/ece5745/handouts.html) 的教材，就分成「ASIC 工具前端」「ASIC 工具後端」「自動化流程」，並教授硬體描述語言、CMOS 電路、合成演算法、實體設計自動化演算法，以及 OpenLANE 等開源流程。

## 4. 心得

1. **EDA 是 IC 的「編譯器」**：以前我以為晶片是畫出來的，其實現在是「寫」出來的，再交給 EDA 自動轉成實體佈局。
2. **測試驅動很重要**：nand2tetris 的 `.tst` / `.cmp` 讓我在做 RAM8 → RAM16K、CPU → Computer 時，一層一層確認正確，後面的元件才不會建立在錯誤的基礎上。
3. **抽象層次**：Nand → 基本閘 → ALU / RAM → CPU → Computer，每一層只需要信任下一層的介面，這正是 EDA 能處理數十億電晶體的原因。
4. **開源 EDA 讓學習門檻降低**：veryl2chip、SKY130、OpenLANE / OpenROAD 這些開源工具，讓學生也能完整體驗晶片設計的後端流程。

## 參考資料

* AI 自製 EDA — https://github.com/ccc-eda/veryl2chip/ ，線上使用：https://ccc-eda.github.io/veryl2chip/web/dist/index.html
* Nand2tetris 網頁專案 — https://github.com/ccc-js/hack-computer ，線上使用：https://ccc-js.github.io/hack-computer/dist/hdl.html
* EDA 電子書 — https://github.com/ccc-eda/eda-books/tree/main/book
* 康乃爾大學 IC 設計課程 — https://www.csl.cornell.edu/courses/ece5745/handouts.html
* 陳鍾誠老師 YouTube 頻道 — https://www.youtube.com/@ccckmit
* nand2tetris 官方網站 — https://www.nand2tetris.org/
