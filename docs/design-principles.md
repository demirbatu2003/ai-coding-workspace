# Design Principles — ai-coding-workspace

Bu belge `docs/architecture.md` §3'teki prensiplerin özet halidir ve günlük çalışırken
hızlı referans olarak kullanılır.

## 1. Basitlik

Sistem az bileşenle çok iş yapmalı. Yeni bileşen yalnızca gerçek bir problemi çözüyorsa
eklenir.

## 2. Ajan bağımsızlığı

Tek bir AI sağlayıcısına bağımlı olunmaz. Ortak dosya formatları (AGENTS.md, Markdown,
Git) temel taşlardır.

## 3. Bağlamı gerektiği kadar kullanma

Bilgi üç seviyede ele alınır: her zaman gerekli, göreve özel, gerektiğinde geri getirilen.

## 4. Kodun bellek olarak kullanılması

Koddan veya git geçmişinden çıkarılabilecek bilgi (dosya adları, klasör yapısı, bağımlılık
listesi) ayrıca kaydedilmez. Bellekte öncelikle şunlar tutulur: mimari kararların
nedenleri, geçici teknik problemler, başarısız olmuş yaklaşımlar, kalıcı kullanıcı
tercihleri.

## 5. Düz metin önceliği

Sistemin büyük kısmı insan tarafından okunabilir/düzenlenebilir dosyalardan oluşur
(Markdown, JSON, YAML). Kritik bilgi kapalı bir veritabanında tutulmaz.

## 6. İnsan kontrolü

Ajan kod yazabilir, dosya değiştirebilir, test çalıştırabilir. Ancak geri döndürülmesi zor
işlemler açık onay ve güvenlik mekanizmalarıyla sınırlandırılır.

## Bilgi nereye ait

| Bilgi türü | Yeri |
|---|---|
| Sabit gerçek (build komutu, konvansiyon) | `AGENTS.md` |
| Tekrarlanan prosedür | Skill |
| Asla ihlal edilmemesi gereken kısıt | Hook |
| Gürültülü, izole yan görev | Subagent |

Bir bilgiyi nereye koyacağını bilemediğinde önce bu tabloya bak.
