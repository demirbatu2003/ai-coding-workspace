---
name: handoff
description: Oturumu kapatırken devir belgesi üretir ve STATE.md'yi günceller. Kullanıcı
  "handoff", "oturumu kapat", "devir", "kaldığımız yeri kaydet" dediğinde veya bağlam
  dolmak üzereyken çalıştır.
---

# Handoff

Bu skill iki ayrı dosyayı günceller — ikisini karıştırma:

- `docs/STATE.md` — üzerine yazılır, "şu an neredeyiz" sorusunun cevabı.
- `docs/handoffs/<bugünün-tarihi>.md` — yeni dosya, bir daha düzenlenmez, "bu oturumda
  ne oldu" sorusunun cevabı.

## Önce topla

1. `git status --short` ve `git diff --stat` — neyin değiştiğini gör.
2. `git log --oneline -10` — son commit'ler.
3. Bu oturumda konuşulanları gözden geçir: ne yapıldı, hangi yaklaşım denenip
   vazgeçildi, hangi kararlar alındı.

Tahmin etme. Bilinmeyen bilgi varsa "bilinmiyor" yaz.

## docs/handoffs/<YYYY-AA-GG>.md yaz

`templates/handoff.md.tmpl` yapısını kullan: Bu Oturumda Ne Yapıldı, Denendi/Olmadı,
Alınan Kararlar, Sonraki Oturuma Not, İlgili Dosyalar.

- Okuyucusu bu projeyi yarın devralacak kişi/ajan — kendine not değil, ona mektup.
- Git'ten okunabilecek şeyi tekrarlama (dosya listesi, diff, commit mesajı).
- "Denendi, Olmadı" bölümü boş geçilmez — hiçbir şey denenmediyse "yok" yaz.
- Bu dosya bir kez yazılır. Yazıldıktan sonra bir daha düzenlenmez.

## docs/STATE.md güncelle

- **Üzerine yaz**, sonuna ekleme yapma.
- 60 satırı geçmesin — her oturum başında bağlama giriyor.
- Tamamlanmış işlerin listesini buraya yazma → `PLANS.md`'ye ait.
- Denenip başarısız olan yaklaşımları buraya yazma → az önce yazdığın handoff'a ait.
- Bölümler: Hedef, Mevcut Durum (branch/build/test), Devam Eden İş, Sonraki Adımlar,
  Açık Problemler, Son Güncelleme.
- Sonraki Adımlar açık ve uygulanabilir olmalı. Yanlış: "Geliştirmeye devam et."
  Doğru: "src/api/auth.py'deki token yenileme mantığını yaz, tests/test_auth.py çalıştır."

## Kalıcı kararları ayır

Bu oturumda alınan ve gelecekte de geçerli olacak mimari/teknik kararlar varsa,
handoff'a yazmakla yetinme — `docs/DECISIONS.md`'ye de ekle (karar + neden + reddedilen
alternatif formatında). Handoff'lar zamanla arşive düşer, DECISIONS.md kalıcıdır.

## Doğrulama

Yazdıktan sonra: `docs/STATE.md` 60 satırı geçmiyor mu, `docs/handoffs/` altında bugünün
tarihiyle tek bir dosya var mı, `PLANS.md`'de bu oturumda biten işler `[x]` işaretli mi.
