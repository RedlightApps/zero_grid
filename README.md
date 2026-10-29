<div align="center">

# 📊 zero_grid

**120Hz 2D-Virtualized DataGrid & Spreadsheet Engine for Flutter.**  
*1,000,000+ rows, left/right column freezing, background `Isolate` sorting/filtering, and Excel-style marquee range selection with TSV clipboard export — Zero external dependencies.*

[![pub package](https://img.shields.io/pub/v/zero_grid.svg?color=00E676&label=pub.dev)](https://pub.dev/packages/zero_grid)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20Android%20%7C%20Web%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux-2979FF)](https://pub.dev/packages/zero_grid)
[![Zero Dependencies](https://img.shields.io/badge/dependencies-ZERO-FF1744)](https://pub.dev/packages/zero_grid)
[![License: MIT](https://img.shields.io/badge/license-MIT-AA00FF)](https://opensource.org/licenses/MIT)
[![RedLight Apps](https://img.shields.io/badge/Crafted%20by-RedLight%20Apps-FF3D00)](https://redlightapps.com)

<br/>

### 🌍 Available Documentation in 11 Languages
[**English**](#english-overview) · [**Türkçe**](#türkçe-genel-bakış) · [**Deutsch**](#deutsch-übersicht) · [**Français**](#français-aperçu) · [**Español**](#español-resumen) · [**Русский**](#русский-обзор) · [**中文**](#中文-概述) · [**日本語**](#日本語-概要) · [**한국어**](#한국어-개요) · [**العربية**](#العربية-نظرة-عامة) · [**Português**](#português-visão-geral)

📚 **Deep-Dive Guides:** [Full Architecture (`DOCUMENTATION.md`)](DOCUMENTATION.md) · [Türkçe Kılavuz (`doc/TR_GUIDE.md`)](doc/TR_GUIDE.md) · [English Guide (`doc/EN_GUIDE.md`)](doc/EN_GUIDE.md)

</div>

---

<a name="english-overview"></a>
## 🇬🇧 English Overview

### Why `zero_grid`?
Flutter's built-in `DataTable` instantiates all rows eagerly and freezes the UI thread past a few hundred records. Existing third-party grids are either **abandoned (`pluto_grid`)** or locked behind **expensive commercial licenses (`syncfusion_flutter_datagrid`)**.

**`zero_grid` solves this under a 100% free MIT license with zero external dependencies:**
1. **`VirtualViewport2D` (1,000,000+ Rows x 100+ Columns @ 120Hz):** Computes visible row spans in $O(1)$ time and visible column spans via $O(\log M)$ binary search. Only the ~200 visible cells on screen are mounted.
2. **Left & Right Column Freezing (`FreezePosition`):** Pin key identifier or action columns to `FreezePosition.left` or `FreezePosition.right` while center columns scroll horizontally.
3. **`IsolateGridEngine` (Non-Blocking Background Isolate):** Multi-column sorting and full-text search automatically offload to `Isolate.run` for large datasets so 120Hz scrolling never drops a frame.
4. **Excel Marquee Selection & TSV Clipboard (`CellRange`):** Select rectangular cell regions and press `Ctrl+C` / `Cmd+C` to copy Tab-Separated Values directly into Microsoft Excel or Google Sheets.
5. **Interactive Column Resizing & Pinned Summary Footer (`GridAggregation`):** Drag header dividers to resize columns live and display automatic `SUM`, `AVG`, `MIN`, `MAX`, or `COUNT` aggregations in a sticky bottom row.

### Quick Start
```yaml
dependencies:
  zero_grid: ^1.0.0
```

```dart
import 'package:zero_grid/zero_grid.dart';

final controller = ZeroGridController<OrderRow>(
  rows: myMillionOrders,
  columns: [
    ZeroGridColumn(
      id: 'id',
      title: 'ORDER #',
      width: 110,
      freeze: FreezePosition.left,
      valueGetter: (r) => r.id,
    ),
    ZeroGridColumn(
      id: 'symbol',
      title: 'SYMBOL',
      width: 130,
      valueGetter: (r) => r.symbol,
    ),
    ZeroGridColumn(
      id: 'notional',
      title: 'NOTIONAL ($)',
      width: 150,
      freeze: FreezePosition.right,
      aggregation: GridAggregation.sum,
      valueGetter: (r) => r.notionalUsd,
    ),
  ],
);

// Inside your build method:
ZeroDataGrid<OrderRow>(controller: controller);
```

---

<a name="türkçe-genel-bakış"></a>
## 🇹🇷 Türkçe — Genel Bakış

`zero_grid`, Flutter için geliştirilmiş **sıfır harici bağımlılıklı, 120Hz 2D sanallaştırılmış DataGrid ve Spreadsheet (Excel) motorudur**.
- **`VirtualViewport2D`:** 1.000.000+ satır ve 100+ sütunu $O(1)$ dikey ve $O(\log M)$ yatay ikili arama ile yalnızca ekranda görünen hücreleri çizerek 120Hz hızında çalıştırır.
- **Sol ve Sağ Sütun Sabitleme (`FreezePosition.left` / `right`):** Kritik sütunları sola veya sağa dondururken orta sütunları pürüzsüzce kaydırır.
- **Arka Plan `Isolate` Sıralama ve Filtreleme (`IsolateGridEngine`):** Büyük veri setlerinde sıralama ve aramayı `Isolate.run` ile arka plana yıkarak ana UI iş parçacığını asla kilitlemez.
- **Excel Hücre Aralığı Seçimi ve TSV Pano (`Ctrl+C` / `Cmd+C`):** Seçilen hücre bölgesini doğrudan Excel veya Google Sheets'e yapıştırılabilir TSV formatında kopyalar.

---

<a name="deutsch-übersicht"></a>
## 🇩🇪 Deutsch — Übersicht

`zero_grid` ist eine **2D-virtualisierte 120Hz DataGrid- und Spreadsheet-Engine** für Flutter ohne externe Abhängigkeiten:
- **1.000.000+ Zeilen (`VirtualViewport2D`):** $O(1)$ Zeilen- und $O(\log M)$ Spalten-Virtualisierung.
- **Spalten-Fixierung (`FreezePosition`):** Fixieren Sie Spalten links oder rechts.
- **Hintergrund-`Isolate` (`IsolateGridEngine`):** Blockierungsfreies Sortieren, Filtern und Excel-TSV-Zwischenablage.

---

<a name="français-aperçu"></a>
## 🇫🇷 Français — Aperçu

`zero_grid` est un **moteur DataGrid et tableur virtualisé 2D à 120Hz** pour Flutter sans dépendance externe :
- **1 000 000+ lignes (`VirtualViewport2D`)**, colonnes figées à gauche/droite (`FreezePosition`), tri/filtrage dans un `Isolate` d'arrière-plan et export presse-papiers TSV compatible Excel.

---

<a name="español-resumen"></a>
## 🇪🇸 Español — Resumen

`zero_grid` es un **motor DataGrid y hoja de cálculo virtualizado 2D a 120Hz** para Flutter sin dependencias externas:
- Soporta más de **1.000.000 de filas**, fijación de columnas a izquierda y derecha (`FreezePosition`), ordenación/filtrado en `Isolate` de fondo y copia TSV directa a Excel (`Ctrl+C`).

---

<a name="русский-обзор"></a>
## 🇷🇺 Русский — Обзор

`zero_grid` — это **2D-виртуализированный движок таблиц DataGrid и электронных таблиц 120Hz** для Flutter без внешних зависимостей:
- **1 000 000+ строк (`VirtualViewport2D`)**, закрепление столбцов слева/справа (`FreezePosition`), сортировка и фильтрация в фоновом `Isolate` и копирование диапазонов ячеек в Excel (TSV).

---

<a name="中文-概述"></a>
## 🇨🇳 中文 — 概述

`zero_grid` 是专为 Flutter 打造的**零外部依赖 120Hz 二维虚拟化数据表格与电子表格引擎**：
- 支持 **1,000,000+ 行与 100+ 列 (`VirtualViewport2D`)**、左右列冻结 (`FreezePosition`)、后台 `Isolate` 无阻塞排序与过滤 (`IsolateGridEngine`)，以及 Excel 兼容的矩形选区 TSV 剪贴板复制 (`Ctrl+C`)。

---

<a name="日本語-概要"></a>
## 🇯🇵 日本語 — 概要

`zero_grid` は外部依存ゼロの **Flutter 向け 120Hz 2D 仮想化 DataGrid & スプレッドシートエンジン**です。
- **100万行以上 (`VirtualViewport2D`)**、左右カラム固定 (`FreezePosition`)、バックグラウンド `Isolate` による非ブロッキングソート・フィルタリング、Excel 互換 TSV クリップボードコピーを内蔵しています。

---

<a name="한국어-개요"></a>
## 🇰🇷 한국어 — 개요

`zero_grid`는 외부 의존성이 전혀 없는 **Flutter용 120Hz 2D 가상화 DataGrid 및 스프레드시트 엔진**입니다.
- **1,000,000행 이상 (`VirtualViewport2D`)**, 좌/우 열 고정 (`FreezePosition`), 백그라운드 `Isolate` 정렬/필터링 및 Excel 호환 TSV 클립보드 복사를 지원합니다.

---

<a name="العربية-نظرة-عامة"></a>
## 🇸🇦 العربية — نظرة عامة

`zero_grid` هو **محرك جداول بيانات (DataGrid & Spreadsheet) ثنائي الأبعاد بسرعة 120Hz** لـ Flutter بدون أي تبعيات خارجية:
- يدعم أكثر من **1,000,000 صف (`VirtualViewport2D`)**، وتثبيت الأعمدة يميناً ويساراً (`FreezePosition`)، والفرز والتصفية في الخلفية عبر `Isolate`، والنسخ المباشر إلى Excel بصيغة TSV.

---

<a name="português-visão-geral"></a>
## 🇧🇷 Português — Visão Geral

`zero_grid` é um **motor DataGrid e planilha virtualizado 2D a 120Hz** para Flutter com zero dependências externas:
- Suporta **1.000.000+ linhas (`VirtualViewport2D`)**, congelamento de colunas à esquerda/direita (`FreezePosition`), ordenação/filtragem em `Isolate` e exportação TSV para Excel.

---

## 💖 Sponsor & Support

Crafted with precision by **[RedLight Apps](https://redlightapps.com)** (Yusuf Kaval).
- ☕ [Buy Me a Coffee](https://www.buymeacoffee.com/yusufkaval)
- 💜 [GitHub Sponsors (@kvlyusuf)](https://github.com/sponsors/kvlyusuf)
- 🌐 [RedLight Apps Official Website](https://redlightapps.com)
