# `zero_grid` — Türkçe Mimari ve Kullanım Kılavuzu

## 1. Neden `zero_grid`?
Flutter'ın standart `DataTable` bileşeni tüm satırları aynı anda bellekte oluşturduğu için birkaç yüz satırdan sonra arayüzü dondurur. `zero_grid`, `VirtualViewport2D` motoruyla **1.000.000+ satır ve 100+ sütunu** yalnızca ekranda görünen hücreleri oluşturarak 120Hz hızında çizer.

## 2. Temel Özellikler
- **Sol ve Sağ Sütun Dondurma (`FreezePosition.left` / `FreezePosition.right`):** Sabit sütunlar yatay kaydırmadan etkilenmez.
- **Arka Plan `Isolate` Sıralama ve Filtreleme (`IsolateGridEngine`):** `Isolate.run` ile büyük veri setlerinde ana UI thread'ini bloklamadan sıralama ve filtreleme yapar.
- **Excel TSV Pano Kopyalama (`Ctrl+C` / `Cmd+C`):** Seçilen hücre aralığını (`CellRange`) doğrudan Excel ve Google Sheets'e yapıştırılabilir formatta panoya kopyalar.
- **Otomatik Alt Özet Satırı (`GridAggregation`):** `sum`, `average`, `min`, `max` ve `count` özetlerini sabit alt barda gösterir.
