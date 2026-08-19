---
name: plan
description: Bir görevi implement etmeden önce adım adım planlar ve PLANS.md'ye yazar.
  Kullanıcı "planla", "plan yap", "önce bir plan çıkar" dediğinde veya görev birden fazla
  aşamadan oluşuyorsa çalıştır.
---

# Plan

Bu skill kod yazmaz. Yalnızca ne yapılacağını, hangi sırayla, hangi dosyalarda
belirler.

## Ne zaman gerekli

Görev tek bir dosyada küçük bir değişiklikten ibaretse plan gereksiz — direkt uygula.
Görev birden fazla dosyaya yayılıyorsa, mimari bir karar içeriyorsa veya birden fazla
oturuma yayılacaksa önce planla.

## Yap

1. İlgili kodu ve mevcut yapıyı oku — mevcut fonksiyon/desenleri yeniden icat etme.
2. Belirsiz noktaları kullanıcıya sor; varsayım yaparak ilerleme.
3. Görevi küçük, doğrulanabilir adımlara böl. Her adım bağımsız test edilebilir olmalı.
4. Adımları `PLANS.md`'ye yaz (`templates/PLANS.md.tmpl` yapısını kullan): Ana Hedef,
   Aşamalar (checkbox'lı), Mevcut İlerleme, Kararlar, Açık Sorular, Riskler.

## Kurallar

- Bir madde `[x]` işaretlenmeden önce ilgili dosyanın diskte gerçekten var ve dolu
  olduğu doğrulanır. Yapılmamış işi tamamlanmış göstermek bu projedeki en ciddi hatadır.
- Plan yazarken kod yazma, dosya değiştirme — yalnızca PLANS.md güncellenir.
- Genel/kalıcı mimari kararlar `docs/DECISIONS.md`'ye gider, bu plana özel olanlar
  `PLANS.md`'nin "Kararlar" bölümünde kalır.
- Plan gereksiz ayrıntı içermez: "adım adım nasıl kodlanacağı" değil, "hangi dosyada ne
  değişecek" seviyesinde kalır.

## Doğrulama

Plan yazıldıktan sonra kullanıcıya onaylatılır. Onay gelmeden implementasyona geçilmez.
