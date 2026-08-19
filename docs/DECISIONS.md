# DECISIONS — ai-coding-workspace

Koda bakarak anlaşılamayan kararlar buraya eklenir. Sona eklenir, üzerine yazılmaz,
eski kayıtlar silinmez.

---

## AGENTS.md tek kaynak, CLAUDE.md sadece import

**Karar:** Talimatlar `AGENTS.md`'de tutulur. `CLAUDE.md` tek satırlık `@AGENTS.md`
importundan ibarettir.
**Neden:** İki dosyaya aynı kuralı yazmak zamanla ayrışmaya yol açar. `AGENTS.md` Codex,
Cursor, Windsurf gibi araçlar tarafından da okunuyor; `CLAUDE.md` sadece Claude Code'a özel.
**Reddedilen:** Symlink ile bağlamak — Windows'ta admin/developer mode gerektirir,
`core.symlinks` ayarına bağımlıdır, klonlayanda bozulabilir.
**Tarih:** 2026-08-15

---

## `.claude/` kullanılır, `.agents/` değil

**Karar:** Araç-özel dosyalar `.claude/` altında tutulur.
**Neden:** Claude Code `.agents/skills` gibi bir yol okumaz; sadece `.claude/` içine bakar.
**Reddedilen:** `.agents/` — bir araştırma kaynağı bunu önermişti ama teknik olarak
Claude Code'da çalışmıyor.
**Tarih:** 2026-08-15

---

## Hook'lar M0-M2 kapsamında, sonraya bırakılmadı

**Karar:** `SessionStart` ve `PreCompact` hook'ları erken aşamada (M2) eklenir.
**Neden:** Resume probleminin deterministik çözümü budur. Talimatla "her oturumda
STATE.md'yi oku" demek tavsiyedir, hook garantidir.
**Reddedilen:** Hook'ları "ileri seviye" kabul edip en sona bırakmak.
**Tarih:** 2026-08-15

---

## Vektör tabanlı hafıza sistemi eklenmiyor

**Karar:** Mem0/memsearch gibi harici vektör hafıza katmanları kullanılmıyor.
**Neden:** Tek geliştirici + tek makine için git + markdown yeterli. Ölçülmüş bir acı
doğarsa sonra eklenir.
**Reddedilen:** Vektör tabanlı "sonsuz hafıza" — bir araştırma kaynağı önermişti.
**Tarih:** 2026-08-15

---

## Multi-agent rol zinciri kurulmuyor

**Karar:** Researcher→Planner→Coder→Tester→Reviewer gibi kalıcı bir çoklu-ajan mimarisi
kurulmuyor.
**Neden:** Faz ayrımı (plan → implement → review, ayrı temiz bağlamlarda) aynı işi
3-10× token maliyeti olmadan yapıyor.
**Reddedilen:** Kalıcı multi-agent orkestrasyon mimarisi.
**Tarih:** 2026-08-15

---

## Şablonlardaki yazım kuralları dosyanın kendisinde tutulmaz

**Karar:** Durum dosyalarının (STATE, DECISIONS, PLANS) nasıl yazılacağına dair kurallar
ilgili skill'in gövdesinde tutulur. Dosyanın kendisinde yalnızca tek satırlık işaretçi
bırakılır.
**Neden:** Bu dosyalar her oturum başında bağlama giriyor. Kuralı orada tutmak sabit
token maliyeti demek; silmek ise kuralın kaybolması demek. Skill gövdesi yalnızca ilgili
komut çalıştığında yükleniyor.
**Reddedilen:** (a) Doldurunca yorumu silmek — kural zamanla kaybolur. (b) Yorumu kalıcı
bırakmak — her oturumda gereksiz token.
**Tarih:** 2026-08-19
