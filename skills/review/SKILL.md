---
name: review
description: Bir diff'i veya değişikliği düzenlemeden inceler; doğruluk, tutarlılık ve
  gereksiz karmaşıklık açısından değerlendirir. Kullanıcı "review", "incele", "gözden
  geçir", "kontrol et" dediğinde çalıştır.
---

# Review

Bu skill kod yazmaz veya düzeltmez. Yalnızca inceler ve bulgularını raporlar.

## Kapsam

`git diff` (staged + unstaged) veya kullanıcının belirttiği dosyalar/PR. Kapsam
belirsizse kullanıcıya sor, tahmin etme.

## Kontrol et

1. **Doğruluk** — değişiklik gerçekten istenen problemi çözüyor mu, edge case'ler
   düşünülmüş mü.
2. **Mevcut kodla tutarlılık** — proje konvansiyonlarına uyuyor mu, benzer bir çözüm
   zaten var mı (varsa neden yeniden yazıldı).
3. **Gereksiz karmaşıklık** — ihtiyaç olmayan soyutlama, kullanılmayan kod, aşırı
   genelleme var mı.
4. **AGENTS.md/DECISIONS.md ile çelişki** — bu projede daha önce alınmış bir karara
   aykırı bir şey yapılmış mı.

## Raporla

Bulguları önem sırasına göre listele: dosya + satır + ne yanlış + neden önemli. Küçük
stil tercihlerini (isimlendirme zevki gibi) doğruluk sorunlarıyla aynı ağırlıkta sunma.

Sorun yoksa "sorun yok" de — bulgu uydurma.

## Doğrulama

Review bir düzeltme değildir. Kullanıcı ayrıca "düzelt" demedikçe hiçbir dosyaya
dokunulmaz.
