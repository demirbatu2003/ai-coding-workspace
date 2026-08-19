---
name: resume
description: Oturum başında projenin durumunu özetler ve sıradaki adımı önerir. Kullanıcı
  "resume", "devam et", "kaldığımız yerden devam", "nerede kalmıştık" dediğinde çalıştır.
---

# Resume

Yeni bir oturumun sıfır bağlamla projenin neresinde olduğunu anlamasını sağlar.

## Hook zaten çalıştıysa tekrarlama

`SessionStart` hook'u bu bilgiyi zaten oturum başında bağlama enjekte ediyorsa (STATE.md,
en yeni handoff, git log/status), onu tekrar okuyup özetleme — hook çıktısı zaten orada.
Bu skill, hook kurulu değilken veya kullanıcı elle `/resume` çağırdığında devreye girer.

## Oku

1. `docs/STATE.md` — şu anki hedef, durum, sıradaki adımlar, açık problemler.
2. `docs/handoffs/` içindeki **en yeni** dosya (tarihe göre sırala) — son oturumda ne
   denendi, ne işe yaramadı, hangi karar alındı.
3. `git log --oneline -10` ve `git status --short` — gerçek kod durumu STATE.md ile
   tutarlı mı diye kontrol et.

## Özetle

5-10 satırı geçmeyen bir özet ver:

- Proje şu an nerede (1-2 cümle)
- Son oturumda önemli olan şey (varsa: denenip vazgeçilen bir yaklaşım, alınan bir karar)
- Sıradaki adım — STATE.md'deki "Sonraki Adımlar" listesinden, spesifik ve uygulanabilir

## Tutarsızlık varsa söyle

`git status` STATE.md'nin anlattığından farklı bir tablo çiziyorsa (örn. STATE.md
"working tree temiz" diyor ama commit edilmemiş değişiklik var), bunu sessizce görmezden
gelme — kullanıcıya söyle. STATE.md bayat olabilir.

## Doğrulama

Özetin sonunda kullanıcıya uzun bir dosya listesi veya commit geçmişi dökülmez — bu bilgi
zaten git'te var. Tek bir net öneri sunulur: şimdi ne yapılacağı.
