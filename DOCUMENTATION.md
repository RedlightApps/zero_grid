# `zero_grid` — Architecture & Engineering Reference

## 1. 2D Viewport Virtualization (`VirtualViewport2D`)

Given `totalRows` ($N$), fixed `rowHeight` ($H_r$), and a list of variable center column widths $[w_0, w_1, \dots, w_{M-1}]$, `VirtualViewport2D.compute` builds cumulative prefix sums:

$$x_j = \sum_{k=0}^{j-1} w_k$$

- **Vertical Window ($O(1)$):**
  $$\text{firstRow} = \max\left(0, \left\lfloor \frac{\text{scrollY}}{H_r} \right\rfloor - \text{overscanRows}\right)$$
  $$\text{lastRow} = \min\left(N - 1, \left\lceil \frac{\text{scrollY} + \text{viewportHeight}}{H_r} \right\rceil + \text{overscanRows}\right)$$
- **Horizontal Window ($O(\log M)$):** Uses binary search over the monotonic prefix array $x_j$ to locate the first and last visible center columns.

## 2. Background Isolate Pipeline (`IsolateGridEngine`)

When row count exceeds `isolateThreshold` (default `2000`), `ZeroGridController` extracts primitive comparable keys on the main isolate and dispatches index sorting or substring matching to `Isolate.run(...)`. This guarantees zero UI frame drops during 100,000+ row sorts.

## 3. Left & Right Freeze Panes (`FreezePosition`)

Columns are partitioned into three horizontal bands (`leftCols`, `centerCols`, `rightCols`). Left and right bands stay pinned to the viewport edges while `centerCols` translate by `-scrollX` inside a clipped `OverflowBox`.
