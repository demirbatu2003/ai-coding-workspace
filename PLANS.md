# PLANS — ai-coding-workspace

## Ana Hedef

Claude Code (sonra Codex) için yeniden kullanılabilir, install edilebilir bir AI kodlama
altyapısı hub'ı oluşturmak. Kapsamlı içerik için IMPLEMENTATION-PLAN.md.

## Aşamalar

### M0 — Hub'ın kendi temeli

- [x] Kök AGENTS.md yazıldı
- [x] CLAUDE.md (@AGENTS.md import) oluşturuldu
- [x] Klasör adları düzeltildi (templates, skills, hooks, settings)
- [x] skills/rewiev → skills/review yeniden adlandırıldı
- [x] .gitignore dolduruldu
- [x] templates/AGENTS.md.tmpl yazıldı
- [x] templates/STATE.md.tmpl yazıldı (yazım kuralları skill'e taşındı)
- [x] templates/handoff.md.tmpl yazıldı
- [x] templates/CLAUDE.md.tmpl yazıldı
- [x] templates/DECISIONS.md.tmpl yazıldı
- [x] templates/PLANS.md.tmpl yazıldı
- [x] docs/STATE.md dolduruldu
- [x] docs/DECISIONS.md dolduruldu (5 sabit karar + şablon-yorum kararı)
- [x] LICENSE dolduruldu
- [x] README.md dolduruldu
- [x] docs/design-principles.md dolduruldu
- [x] docs/architecture.md §4 hub/hedef ayrımına göre güncellendi
- [x] M0 kapanış commit'i atıldı
- [x] İlk handoff (docs/handoffs/2026-08-19.md) yazıldı — ajan tarafından, çünkü bu işi
      normalde /handoff skill'i yapacak; skill henüz kurulmadığı için (M1) bu ilk sefer
      elle simüle edildi

### M1 — Skills

- [ ] skills/handoff/SKILL.md frontmatter eklendi, iki-dosya modeline göre revize edildi
- [ ] skills/resume/SKILL.md yazıldı
- [ ] skills/plan/SKILL.md yazıldı
- [ ] skills/review/SKILL.md yazıldı

### M2 — Hooks

- [ ] hooks/session-start.ps1 + .sh
- [ ] hooks/pre-compact.ps1 + .sh
- [ ] settings/settings.json.fragment

### M3 — Kurulum script'i

- [ ] install.ps1
- [ ] install.sh

### M4 — doctor

- [ ] scripts/doctor.ps1 + .sh

### M5 — Dogfooding

- [ ] .claude/ gitignore (zaten .gitignore'da var, doğrulanacak)
- [ ] Hub kendi kendine kurulur, uçtan uca test edilir

## Mevcut İlerleme

- Mevcut aşama: M0 tamamlandı, M1'e (Skills) geçiliyor
- Genel durum: Kök dosyalar, şablonlar, durum dosyaları ve ilk handoff tamam. Sıradaki iş
  skills/handoff/SKILL.md'ye frontmatter eklemek ve diğer 3 skill'i yazmak.

## Kararlar

Genel/kalıcı kararlar için bkz. docs/DECISIONS.md.

## Sürprizler ve Bulgular

- Bash aracının git görünümü gerçek diskle senkron olmayabiliyor; git durumu doğrulanırken
  kullanıcının kendi terminal çıktısına güvenilmeli.

## Açık Sorular

Yok.

## Riskler

- `PLANS.md`'de bir maddeyi `[x]` işaretlemeden önce dosyanın gerçekten dolu olduğu
  doğrulanmalı — bu proje bunu ilke edinmiş durumda, listeyi güncellerken buna dikkat.

## Son Güncelleme

2026-08-19
