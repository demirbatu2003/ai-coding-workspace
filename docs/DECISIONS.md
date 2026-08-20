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

---

## install.sh'te JSON birleştirme için python3'e bağımlı kalınıyor

**Karar:** `install.sh`, `.claude/settings.json`'ı birleştirirken `python3` kullanır.
`python3` yoksa hiçbir şeye dokunmadan uyarıp atlar; asla ham metin üzerinde JSON
değiştirmeye çalışmaz.
**Neden:** Windows yollarındaki `\` gibi karakterler JSON'da geçersiz kaçış dizisi
oluşturabilir. Saf bash'te güvenli bir JSON parser yok; ham metin manipülasyonu
kullanıcının var olan `settings.json`'ını bozma riski taşır — bu, projenin "asla mevcut
ayarları ezme" kuralını ihlal eder. `python3` Linux/Mac'te neredeyse her zaman kurulu.
**Reddedilen:** (a) Ham metin string-replace ile JSON üretmek — geçersiz JSON riski.
(b) `jq` gibi ek bir bağımlılık eklemek — daha az yaygın, ayrı bir kurulum adımı ister.
**Tarih:** 2026-08-20

---

## Aynı gün ikinci `/handoff` her zaman yeni dosya üretir

**Karar:** `/handoff` aynı gün içinde birden fazla kez çalıştırılırsa, her çağrı
`docs/handoffs/<tarih>-N.md` biçiminde yeni bir dosya üretir (N=2,3,…; ilk çağrı eksiz
`<tarih>.md`). Aradan geçen sürede yeni içerik olsun olmasın — üzerine yazma yok, no-op
yok.
**Neden:** Handoff dosyaları "bir kez yazılır, düzenlenmez" kuralına tabi; üzerine
yazmak bu kuralı çiğner. No-op ise `/handoff` çağrısının davranışını konuşmanın
içeriğine göre belirsizleştirir (bazen dosya üretir, bazen üretmez) — deterministik
değil. Sabit "her zaman yeni dosya" kuralı basit ve öngörülebilir.
**Reddedilen:** (a) Üzerine yazmak — dondurulmuş dosya kuralını çiğner. (b) Yeni içerik
yoksa no-op — davranışı içerik değerlendirmesine bağlar, test edilmesi zor hale gelir.
**Tarih:** 2026-08-20

---

## `.ai-workspace/version.json` git'e girer, gitignore'a girmez

**Karar:** `.ai-workspace/version.json` (install script'in ürettiği hubVersion/
installedAt/installedFiles "kurulum makbuzu") git'te takip edilir, `.gitignore`'a
eklenmez.
**Neden:** `scripts/doctor` (M4) bu dosyayı okuyup "kurulu sürüm, hub'ın güncel
sürümünden eski mi" diye kaynak/hedef sapmasını otomatik yakalayabilecek — tam olarak
bu oturumda elle bulduğumuz `skills/`↔`.claude/skills/` sapma sorununu bir daha elle
aramaya gerek kalmadan tespit etmek için. Bu fayda, `installedAt` alanının her yeniden
kurulumda küçük bir git değişikliği yaratmasından daha değerli görüldü.
**Reddedilen:** Gitignore'a eklemek — makine-özel/geçici bir dosya gibi davranmak.
Reddedildi çünkü bu, doctor'ın sapma tespiti yapabilmesi için gereken bilgiyi
klonlayan/paylaşan herkesten gizlerdi.
**Tarih:** 2026-08-20

---

## `/handoff` yalnızca elle çalışır, hassas bilgiyi redakte eder

**Karar:** `skills/handoff/SKILL.md`'ye iki kural eklendi: (1) `disable-model-invocation:
true` frontmatter alanı — model bu skill'i kendiliğinden tetikleyemez, sadece kullanıcı
açıkça çağırabilir; (2) yazmadan önce API key/token/şifre/kişisel kimlik gibi hassas
verinin `[REDACTED]` ile değiştirilmesi zorunlu.
**Neden:** `mattpocock/skills` reposunun `handoff` skill'i incelenirken iki eksik fark
edildi. `/handoff` git'e kalıcı yazan, geri alınması zor bir işlem — modelin "bağlam
doluyor gibi" diye kendiliğinden tetiklemesi riskli, kullanıcı onayı gerektirmeli. Ayrıca
handoff dosyaları git'e kalıcı girdiği için, konuşmada paylaşılan bir sırrın (API key
vb.) farkında olmadan commit edilmesi gerçek bir güvenlik riski.
**Reddedilen:** Redaksiyonu ayrı bir doğrulama adımına bırakmak — riskli, unutulabilir;
kural skill'in gövdesine, yazma adımından önce yerleştirildi ki atlanamasın.
**Tarih:** 2026-08-20
