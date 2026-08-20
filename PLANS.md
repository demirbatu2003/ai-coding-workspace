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

- [x] skills/handoff/SKILL.md frontmatter eklendi, iki-dosya modeline göre revize edildi
- [x] skills/resume/SKILL.md yazıldı
- [x] skills/plan/SKILL.md yazıldı
- [x] skills/review/SKILL.md yazıldı

### M2 — Hooks

- [x] hooks/session-start.ps1 + .sh — elle test edildi, encoding sorunu (BOM'suz UTF-8 +
      PowerShell 5.1 ANSI varsayımı) bulunup `-Encoding UTF8` ile düzeltildi
- [x] hooks/pre-compact.ps1 + .sh — elle test edildi
- [x] settings/settings.json.fragment — `{{SESSION_START_CMD}}`/`{{PRE_COMPACT_CMD}}`
      yer tutucularıyla, install script'in dolduracağı şablon

### M3 — Kurulum script'i

- [x] install.ps1 — 5 adımlı (git kontrolü, template kopyalama, skills/hooks kopyalama,
      settings.json birleştirme, version.json yazma), dry-run + gerçek çalıştırma ile
      test edildi
- [x] install.sh — install.ps1 ile birebir aynı mantık; JSON birleştirme için python3
      kullanıyor (yoksa elle birleştirmeye yönlendirip dokunmadan atlıyor). Syntax
      kontrolünden geçti (`bash -n`), gerçek çalıştırmayla henüz test edilmedi

### M4 — doctor

- [ ] scripts/doctor.ps1 + .sh

### M5 — Dogfooding

- [x] `.claude/skills/`, `.claude/hooks/` gitignore'da (doğrulandı: `git check-ignore -v`
      ile ikisi de ignore ediliyor; `.claude/settings.json` ve `.ai-workspace/` ise
      **ignore edilmiyor** — bilinçli mi değil mi netleşmedi, bkz. Açık Sorular)
- [x] Hub kendi kendine kuruldu (`.\install.ps1 -Target .`, gerçek çalıştırma) — skills
      ve hooks `.claude/` altına kopyalandı, `settings.json` doğru JSON kaçışıyla üretildi
- [x] **Asıl doğrulama tamamlandı (2026-08-20):** küçük, git'te görülür bir değişiklik
      yapılıp commit'lendi (`615bb66`), proje kök dizininden yeni bir oturum açıldı,
      `SessionStart` hook'u otomatik tetiklenip git status'u context'e enjekte etti,
      `/resume` doğru özet üretti. Detay: `docs/handoffs/2026-08-20-3.md`.

## Mevcut İlerleme

- Mevcut aşama: M0-M3 ve M5 tamam. Sırada M4 (`scripts/doctor.ps1` + `.sh`) var.
- M5'in uçtan uca testi (`/handoff`→yeni oturum→`/resume`) 2026-08-20'de geçti, detay
  `docs/handoffs/2026-08-20-3.md`'de.

## Kararlar

Genel/kalıcı kararlar için bkz. docs/DECISIONS.md.

## Sürprizler ve Bulgular

- Bash aracının git görünümü gerçek diskle senkron olmayabiliyor; git durumu doğrulanırken
  kullanıcının kendi terminal çıktısına güvenilmeli. (Not: dosya okuma/yazma işlemleri
  için bu sorun gözlenmedi, yalnızca git komutlarında — muhtemelen o günkü olay reset
  komutunun gerçekten diske yansımasıydı, sandbox izolasyonu değil.)
- PowerShell 5.1, BOM'suz UTF-8 dosyaları `Get-Content` ile okurken sistem ANSI kod
  sayfasını varsayıyor — Türkçe karakterler bozuluyor. `-Encoding UTF8` şart.
- `ConvertTo-Json` backslash kaçışını (Windows yollarındaki `\`) otomatik doğru yapıyor;
  bu yüzden JSON'a placeholder'ı önce parse edip bellekte değiştirmek, ham metin üzerinde
  string-replace yapmaktan daha güvenli (JSON'da tek `\` geçersizdir).
- Saf bash'te güvenli JSON birleştirme yok; `python3`'e bağımlı kalmak (yoksa sessizce
  atlayıp raporlamak) "asla mevcut ayarları bozma" kuralını korumanın tek yolu oldu —
  "install script bağımlılıksız" ilkesinden küçük, bilinçli bir sapma.
- Claude Code'un skill-keşif mekanizması gerçekten çalışıyor: `.claude/skills/` altına
  kopyalanan 4 skill, sistem hatırlatmasında otomatik listelendi — M1'in "henüz canlı
  test edilmedi" notu artık kapandı.

## Açık Sorular

1. ~~Aynı gün ikinci `/handoff` ne olacak?~~ **Çözüldü (2026-08-20):** her zaman
   `docs/handoffs/<tarih>-N.md` biçiminde yeni dosya üretilir, içerik olsun olmasın.
   Ayrıntı ve gerekçe `docs/DECISIONS.md`'de. `skills/handoff/SKILL.md` bu kurala göre
   güncellendi.
2. ~~`skills/resume` ile Claude Code'un kendi `/resume`'u çakışıyor mu?~~ **Çözüldü
   (2026-08-20):** çakışma yok. M5 testinde `/resume` çağrıldığında `skills/resume`
   normal şekilde tetiklendi, doğru özet üretti. Detay: `docs/handoffs/2026-08-20-3.md`.
3. **`.ai-workspace/version.json` gitignore'a girmeli mi?** Şu an girmiyor (`git add -A`
   onu staged ediyor). Hedef projeler için muhtemelen tutulmalı (doctor'ın "hub
   güncellenmiş mi" kontrolü buna dayanıyor) ama hub'ın kendi self-install'ı için gereksiz
   olabilir. Karar verilmedi.

## Riskler

- `PLANS.md`'de bir maddeyi `[x]` işaretlemeden önce dosyanın gerçekten dolu olduğu
  doğrulanmalı — bu proje bunu ilke edinmiş durumda, listeyi güncellerken buna dikkat.

## Son Güncelleme

2026-08-20
