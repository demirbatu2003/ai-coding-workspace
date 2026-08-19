# STATE — ai-coding-workspace

## Hedef

M2'yi (Hooks) tamamlamak: `hooks/session-start.ps1`+`.sh` ve
`hooks/pre-compact.ps1`+`.sh` yazmak, `settings/settings.json.fragment` oluşturmak.

## Mevcut Durum

- Branch: master
- Working tree: 4 skill dosyası + PLANS.md/STATE.md güncellemesi henüz commit'lenmedi
- Build: N/A
- Test: skill'lerin Claude Code'da gerçekten yüklendiği (frontmatter geçerliliği) henüz
  canlı test edilmedi — yalnızca dosya yapısı ve satır sayısı elle doğrulandı

## Devam Eden İş

Yok — M1 (dosya bazında) tamamlandı, M2 henüz başlamadı.

## Sonraki Adımlar

1. `hooks/session-start.ps1` + `.sh` yaz: STATE.md + en yeni handoff + git log/status'u
   stdout'a bas. Dosyalar yoksa sessizce çık.
2. `hooks/pre-compact.ps1` + `.sh` yaz: compaction öncesi hatırlatma + git durumu.
3. `settings/settings.json.fragment` yaz: hook kayıtları.
4. M5'teki self-install ile (`.\install.ps1 -Target .`) skill'lerin Claude Code'da `/`
   yazınca gerçekten listelendiğini doğrula — bu M1'in gerçek doğrulaması, henüz yapılmadı.

## Açık Problemler

Skill'lerin frontmatter'ı elle/statik olarak doğru görünüyor ama Claude Code'da canlı
yüklendiği test edilmedi. `install.ps1` (M3) yazılmadan bu test yapılamaz.

## Son Güncelleme

2026-08-19
