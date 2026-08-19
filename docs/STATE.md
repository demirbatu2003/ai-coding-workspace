# STATE — ai-coding-workspace

## Hedef

M5'in asıl doğrulama testini tamamlamak: `/handoff` → `/clear` → `/resume` döngüsünü
uçtan uca çalıştırıp, yeni bir oturumun eski konuşma geçmişi olmadan doğru yerden devam
edebildiğini kanıtlamak. Bu, projenin varlık sebebinin doğrulanmasıdır.

## Mevcut Durum

- Branch: master
- Working tree: M2 (hooks + settings fragment) ve M3 (install.ps1 + install.sh) dosya
  bazında tamam ama commit'lenmedi. Untracked: `install.ps1`, `install.sh`, `hooks/*`,
  `settings/settings.json.fragment`, `.claude/settings.json`, `.ai-workspace/version.json`.
  (`.claude/skills/`, `.claude/hooks/` doğru şekilde gitignore'da, staged olmuyor.)
- Build: N/A
- Test: install.ps1 dry-run + gerçek çalıştırmayla test edildi (hub kendi kendine
  kuruldu). install.sh yalnızca syntax kontrolünden geçti, gerçek çalıştırma testi yok.
  Skill yüklemesi canlı doğrulandı (4 skill de Claude Code'da listelendi).

## Devam Eden İş

M5 uçtan uca testi başlıyor: küçük bir değişiklik yapılacak, `/handoff` çalıştırılacak,
`/clear`, sonra `/resume` ile sonuç değerlendirilecek.

## Sonraki Adımlar

1. Küçük, git'te görülür bir değişiklik yap.
2. `/handoff` çalıştır — `docs/handoffs/2026-08-19.md` zaten var, aynı gün ikinci
   handoff'ta ne olacağı açık soru (bkz. PLANS.md § Açık Sorular). Gerçek davranışı
   gözlemleyip karar ver.
3. `/clear` — hemen sonra SessionStart hook'unun otomatik context enjekte edip
   etmediğini gözlemle.
4. `/resume` — özetin doğruluğunu, adım 1'deki değişikliği yansıtıp yansıtmadığını
   kontrol et. `skills/resume` ile Claude Code'un kendi resume'unun çakışıp
   çakışmadığına dikkat et (açık soru).
5. Test geçerse: M2+M3 dosyalarını commit'le, açık soruları karara bağla
   (docs/DECISIONS.md'ye yaz), M4'e (doctor) geç.

## Açık Problemler

Üç açık tasarım sorusu var, ayrıntı `PLANS.md` § Açık Sorular'da:
1. Aynı gün ikinci `/handoff` çakışması (üzerine yaz mı, farklı isim mi).
2. `skills/resume` adının Claude Code'un yerleşik resume özelliğiyle çakışması.
3. `.ai-workspace/version.json` gitignore'a girmeli mi (şu an girmiyor).

## Son Güncelleme

2026-08-19
