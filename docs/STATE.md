# STATE — ai-coding-workspace

<!-- Yazım kuralları: .claude/skills/handoff/SKILL.md — bu satır kalsın, silme. -->

## Hedef

M7 — hub'ı gerçek, ayrı bir projeye (`C:\Users\batuh\proje-a`) kurup uçtan uca kullanmak.
M5 self-install'dı; bu, hub'ın başka bir repoda gerçekten çalıştığının testi.

## Mevcut Durum

- Branch: main
- Working tree: temiz. GitHub'a push edilmiş son commit `fd9fbfa`; bu oturumun
  handoff + PLANS.md değişikliği henüz push edilmedi.
- Build: N/A
- Test: `doctor` temiz (0 hata, 0 uyarı), pre-commit hook her commit'te otomatik çalışıyor.

## Devam Eden İş

Yok — M7 planlandı ama henüz başlanmadı.

## Sonraki Adımlar

1. `C:\Users\batuh\proje-a` oluştur, içinde `git init` çalıştır.
2. Hub kökünden kur: `.\install.ps1 -Target ..\proje-a`
3. proje-a'daki `<!-- DOLDUR: -->` alanlarını elle doldur (AGENTS.md, PLANS.md,
   docs/STATE.md, docs/DECISIONS.md).
4. proje-a'da küçük ama gerçek bir şey geliştir — ne olacağı henüz belirlenmedi,
   kullanıcıya sorulacak (boş projede handoff/resume testi yapay kalır).
5. proje-a'da `/handoff` → oturumu kapat → yeni oturum → `/resume` döngüsünü dene.
6. Hub'dan uzaktan: `.\scripts\doctor.ps1 -Target ..\proje-a`

Tam adımlar ve konum kararının gerekçesi `PLANS.md` § M7'de.

## Açık Problemler

1. proje-a'da ne geliştirileceği belirlenmedi (adım 4).
2. Bilinen sınır: `doctor` ve `.githooks/pre-commit` install ile hedefe kopyalanmıyor —
   M7 testinin bunu somutlaştırması bekleniyor.

## Son Güncelleme

2026-08-20 (aynı gün 5. handoff)
