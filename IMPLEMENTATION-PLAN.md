# AI Coding Workspace — Uygulama Rehberi

> Bu dosya bir **elle uygulama rehberidir**. Her adımı sen kendin oluşturacaksın.
> Amaç dosya üretmek değil, neyin nereye ait olduğunu öğrenmek.
> Sırayla ilerle, her aşamanın sonundaki doğrulamayı yapmadan bir sonrakine geçme.

---

## 0. Neden bu proje var?

Yeni bir AI oturumu açtığında ajan projenin nerede kaldığını bilmez. Çözüm, eski oturumu
binlerce token'lık geçmişiyle geri yüklemek **değil**; diskte duran kısa durum dosyalarını
okuyarak **sıfır bağlamla** başlamaktır.

Bu hub, o dosya + skill + hook setini herhangi bir projeye kurulabilir hale getirir.

**Hub'ın var olma sebebi olan bulgu:** LLM'e kendi `AGENTS.md`'sini yazdırmak (`/init`)
görev başarısını ~%3 düşürüp maliyeti ~%20 artırıyor — model kodda zaten görünen şeyleri
özetleyip dosyayı şişiriyor. Bu yüzden çözüm otomatik üretim değil, **insan küratörlüğünden
geçmiş, kısa, doldurulacak yerleri belli bir iskeleti dağıtmak**.

---

## 1. Sabit kararlar

Bunlar araştırmalara ve tartışmaya dayanarak kapandı. Değiştirmek istersen önce
`docs/DECISIONS.md`'ye gerekçesini yaz.

| Konu | Karar |
|---|---|
| Hedef araç | Claude Code önce, Codex sonra |
| Talimat kaynağı | `AGENTS.md` tek kaynak; `CLAUDE.md` sadece `@AGENTS.md` satırı |
| State modeli | `docs/STATE.md` + `docs/DECISIONS.md` + `docs/handoffs/<tarih>.md` + `PLANS.md` |
| Dağıtım | `install.ps1` + `install.sh` (kopyalama, bağımlılık yok) |
| Dil | Türkçe (talimat dosyaları dahil) |

Araştırmalar çeliştiğinde alınan kararlar:

1. **`.claude/` kullanılır, `.agents/` değil.** Claude Code `.agents/skills` diye bir yol
   okumaz. Paylaşılan gerçek kökte, araç-özel katman kendi gizli dizininde.
2. **Symlink yok, `@AGENTS.md` import var.** Windows'ta symlink admin/developer mode ister,
   `core.symlinks` ayarına takılır, klonlayanda bozulur.
3. **Hook'lar baştan var.** `SessionStart` hook'u resume probleminin deterministik çözümü.
   Talimat tavsiyedir, hook garantidir.
4. **Vektör hafıza yok.** Tek geliştirici + tek makine için git + markdown yeterli.
5. **Multi-agent rol zinciri yok.** Faz ayrımı (plan → implement → review, ayrı temiz
   bağlamlarda) aynı işi 3-10× token maliyeti olmadan yapıyor.

---

## 2. En kritik ayrım: HUB ≠ HEDEF

Bu proje en çok buradan bozulur. Şu an `templates/HANDOFF.md` hem şablon hem canlı durum
tutuyor — düzeltilecek ilk şey bu.

```
ai-coding-workspace/  (HUB — dağıtan)          herhangi-bir-proje/  (HEDEF — üretilen)
  templates/*.md.tmpl                            AGENTS.md
  skills/                      install           CLAUDE.md
  hooks/                       ───────►          PLANS.md
  scripts/                                       docs/STATE.md
  install.ps1 / install.sh                       docs/DECISIONS.md
  VERSION                                        docs/handoffs/
  AGENTS.md, docs/  (hub'ın kendisi için)        .claude/skills/, hooks/, settings.json
                                                 .ai-workspace/version.json
```

**Kural:** hub kökündeki hiçbir dosya doğrudan kopyalanmaz. Hedefe giden her şey
`templates/`, `skills/`, `hooks/` altında yaşar. Hub'ın kendi `AGENTS.md` ve `docs/STATE.md`
dosyaları **hub'ın kendi geliştirmesi** içindir.

Kafan karışırsa şunu sor: *"Bu dosya benim bu repoyu geliştirmem için mi, yoksa başka bir
projeye kopyalanacak mı?"* Cevap ikisi birden ise, iki ayrı dosyaya bölmen gerekiyor demektir.

---

## 3. Dört durum dosyasının rolleri

Skill'lerin ve hook'ların ne yazacağını bu ayrım belirler. Karıştırırsan sistem çöker.

| Dosya | Rol | Yazma biçimi |
|---|---|---|
| `docs/STATE.md` | **Şu an** neredeyiz: faz, son yapılanlar, açık işler, açık problemler, sıradaki adım | Üzerine yazılır, hep güncel |
| `docs/handoffs/<tarih>.md` | **O oturum** neydi: ne denendi, ne işe yaramadı, hangi karar alındı | Dondurulur, bir daha düzenlenmez |
| `docs/DECISIONS.md` | Koda bakarak anlaşılamayan **neden**'ler + reddedilen alternatifler | Sona eklenir |
| `PLANS.md` | Uzun görevin adım listesi ve ilerlemesi `[x]` | Güncellenir |

Başarısız yaklaşımların kaydı `handoffs/`'ta kalıcıdır — aynı çıkmaza üç ay sonra tekrar
girmeni engelleyen tek şey budur. `STATE.md` üzerine yazıldığı için bu bilgiyi tutamaz.

---

## M0 — Hub'ın kendi temeli

Önce hub'ı kendi kurallarına uydur, sonra dağıtacağı şeyi üret.

- [ ] `AGENTS.md` (kök) — hub'ın kendi çalışma kuralları. **≤200 satır.**
      Mevcut `templates/AGENTS.md` metnini temel al, ama bu sefer *bu repo için* yaz.
- [ ] `CLAUDE.md` — içinde tek satır: `@AGENTS.md`
- [ ] `docs/STATE.md` — hub'ın canlı durumu. Şu anki gerçeği yaz: hangi aşamadasın.
- [ ] `docs/DECISIONS.md` — ilk kayıtlar yukarıdaki 5 karar. Her kayıt: **karar + neden +
      reddedilen alternatif.**
- [ ] `docs/handoffs/` klasörü (şimdilik boş)
- [ ] `PLANS.md` (kök) — `templates/PLANS.md` içeriğini taşı ve **gerçekle hizala**.
      Şu an "AGENTS.md oluştur `[x]`" diyor ama dosya boş. Bu tam olarak M4'teki `doctor`
      script'inin yakalayacağı kayma; yakalayıcıyı yazmadan önce elle düzelt ki neyi
      yakalayacağını bil.
- [ ] `docs/design-principles.md` (şu an boş) — `docs/architecture.md` §3'teki 6 prensip
      + şu yönlendirme tablosu:

      | Bilgi türü | Nereye ait |
      |---|---|
      | Sabit gerçek (build komutu, konvansiyon) | `AGENTS.md` |
      | Tekrarlanan prosedür (deploy, review) | Skill |
      | Asla ihlal edilmemesi gereken kısıt | Hook |
      | Gürültülü, izole yan görev | Subagent |

- [ ] `README.md`, `LICENSE` (MIT), `.gitignore`
- [ ] `templates/` içindekileri **gerçek şablona** dönüştür:
      `AGENTS.md.tmpl`, `CLAUDE.md.tmpl`, `STATE.md.tmpl`, `DECISIONS.md.tmpl`,
      `PLANS.md.tmpl`, `handoff.md.tmpl`
      - `.md.tmpl` uzantısı bilinçli: canlı dosyayla asla karışmasın.
      - Mevcut `templates/HANDOFF.md` **ikiye bölünür**: `STATE.md.tmpl` (canlı durum) +
        `handoff.md.tmpl` (oturum devri).
      - Doldurulacak yerleri `<!-- DOLDUR: proje adı -->` biçiminde işaretle.
      - Şablonların içinde **bu projenin gerçek verisi kalmasın** — hepsi placeholder olmalı.

- [ ] `docs/architecture.md` §4'teki ağacı güncelle — şu an hub/hedef ayrımını göstermiyor.

**Doğrulama:** `AGENTS.md` satır sayısı 200'ün altında mı? `templates/` içinde bu projeye
özel tek bir gerçek veri kaldı mı? `PLANS.md`'deki her `[x]` diskte gerçekten var mı?

**Bittiğinde commit at.** Buradan sonra her aşama ayrı commit.

---

## M1 — Skills (4 adet)

Konum: `skills/<ad>/SKILL.md`

**İlk düzeltme:** mevcut `skills/handoff/SKILL.md` YAML frontmatter'sız. Claude Code onu
skill olarak yüklemiyor — sadece bir markdown dosyası. Her SKILL.md şöyle başlamalı:

```yaml
---
name: handoff
description: Oturumu kapatırken devir belgesi üretir ve STATE.md'yi günceller. Kullanıcı
  "handoff", "oturumu kapat", "devir", "kaldığımız yeri kaydet" dediğinde çalıştır.
---
```

Bilmen gereken iki şey:
- `name` küçük harf + tire olmalı, klasör adıyla aynı.
- `description` bir **tetikleyicidir**, dokümantasyon değil. Oturum başında yalnızca bu satır
  yüklenir (~100 token); gövde ancak eşleşince gelir. Bu yüzden içine kullanıcının gerçekten
  yazacağı kelimeleri koy — Türkçe **ve** İngilizce (`handoff`, `resume` zaten komut adları).

- [ ] `skills/resume/SKILL.md` — `docs/STATE.md` + en yeni handoff + `git log --oneline -10`
      + `git status` oku → 5-10 satır özet + sıradaki adım önerisi.
      Hook zaten enjekte etmişse tekrar okumasın.
- [ ] `skills/handoff/SKILL.md` — git durumunu ve oturumu analiz et →
      `docs/handoffs/<bugün>.md` **yaz** ve `docs/STATE.md`'yi **güncelle**.
      Mevcut içerik iyi bir başlangıç; tek dosya yerine iki dosya modeline göre revize et.
- [ ] `skills/plan/SKILL.md` — görevi implement **etmeden** planla, `PLANS.md`'ye adım
      listesi yaz. (Mevcut boş `skills/planning/` klasörünü `plan/` olarak yeniden adlandır.)
- [ ] `skills/review/SKILL.md` — diff'i edit **etmeden** incele.

Her SKILL.md gövdesi **≤60 satır** hedefi. Daha uzun referans gerekiyorsa yanına
`reference.md` koy ve skill oradan yönlendirsin (progresif ifşa).

**Doğrulama:** M5'teki self-install'dan sonra Claude Code'da `/` yazınca dördü de listede
görünmeli. Frontmatter'ın gerçekten geçerli olduğunun tek kanıtı budur.

---

## M2 — Hooks

Konum: `hooks/`, ayrıca `settings/settings.json.fragment`

- [ ] `hooks/session-start.ps1` + `hooks/session-start.sh`
      Oturum başında, `/clear`'da, `--resume`'da ve compaction sonrası tetiklenir.
      stdout'a bas: `docs/STATE.md` → `docs/handoffs/` içindeki en yeni dosya →
      `git log --oneline -10` → `git status --short`.
      **Dosyalar yoksa sessizce çık** — hub kurulmamış bir projeyi bozmamalı.
      Bu, "her oturumda STATE.md'yi oku" talimatının deterministik karşılığıdır.

- [ ] `hooks/pre-compact.ps1` + `.sh`
      Compaction öncesi hatırlatma + `git status` / `git diff --stat` anlık görüntüsü.
      **Dürüst sınır:** hook bir komut çalıştırır, modele dosya *yazdıramaz*. Bu hook
      "state kaydedildi" garantisi vermez, sadece hatırlatır. Gerçek garanti `/handoff`'u
      compaction'dan önce çalıştırmakta.

- [ ] `settings/settings.json.fragment` — hook kayıtları. Install script platforma göre
      doğru komutu (`.ps1` / `.sh`) yazacak.

Her iki hook da **tek başına çalışabilir** olmalı: `.\hooks\session-start.ps1` elle
çalıştırıldığında anlamlı çıktı vermeli. Test edilebilirliğin tek yolu bu.

**Doğrulama:** elle çalıştır, çıktı doğru mu. Boş bir dizinde çalıştır, hata vermeden çıkıyor mu.

---

## M3 — Kurulum script'i

- [ ] `VERSION` (kök) — tek doğruluk kaynağı, örn. `0.1.0`
- [ ] `install.ps1` (birincil, Windows)
- [ ] `install.sh` (eşdeğer davranış)

```powershell
.\install.ps1 -Target ..\benim-projem [-Force] [-DryRun]
```

Davranış sırası:

1. Hedef bir git reposu mu? Değilse uyar ve onay iste.
2. `templates/*.md.tmpl` → hedefteki karşılıkları (`.tmpl` uzantısı düşer).
   **Mevcut dosyanın üzerine asla yazma** — varsa atla ve raporla. `-Force` verilirse yazar.
3. `skills/` → `.claude/skills/`, `hooks/` → `.claude/hooks/`
4. `.claude/settings.json`: yoksa oluştur, **varsa hook girdilerini birleştir**.
   Kullanıcının mevcut ayarlarını ezmek bu projede kabul edilemez bir hata.
5. `.ai-workspace/version.json` yaz: hub sürümü, kurulum tarihi, kurulan dosyalar + hash'leri.
6. Özet bas: **yazılanlar / atlananlar / senin doldurman gereken placeholder'lar.**

`-DryRun` hiçbir şey yazmadan aynı raporu üretir. Önce onu yaz, gerçek yazmayı sonra ekle —
böylece test ederken bir şeyi bozma riskin olmaz.

**Doğrulama:**
- Boş test dizininde `git init` → `-DryRun` → rapor doğru mu → gerçek kurulum → ağaç tam mı.
- Hedefte elle bir `AGENTS.md` ve dolu bir `.claude/settings.json` bırak, tekrar kur.
  `AGENTS.md` atlanmalı, mevcut ayarlar korunmalı, hook girdileri eklenmeli.

---

## M4 — doctor (drift yakalayıcı)

- [ ] `scripts/doctor.ps1` + `scripts/doctor.sh` — hedef projede veya hub'ın kendisinde çalışır.

Kontrol listesi:

- `AGENTS.md` ≤200 satır mı
- `STATE.md` son commit'e göre bayat mı (>N gün → uyarı)
- `PLANS.md`'de `[x]` işaretli ama diskte olmayan/boş dosya var mı ← *hub'ın şu anki kayması*
- Her `SKILL.md`'de geçerli frontmatter var mı (`name` küçük-tire, `description` dolu)
- Doldurulmamış `<!-- DOLDUR: -->` kalmış mı
- `version.json` ile hub `VERSION` farklı mı → "hub güncellenmiş" uyarısı
- `settings.json`'daki hook yolları diskte gerçekten var mı

Çıkış kodu: `0` temiz, `1` uyarı, `2` hata.

**Doğrulama:** kasten üç şey boz — `AGENTS.md`'yi 250 satıra çıkar, bir `SKILL.md`'nin
frontmatter'ını sil, `PLANS.md`'de olmayan bir dosyayı `[x]` işaretle. Üçünü de yakalamalı.

---

## M5 — Dogfooding

- [ ] `.\install.ps1 -Target .` — hub kendi kendine kurulur.
      Bu hem hub'ın günlük geliştirmesini skill/hook'lu hale getirir, hem de install
      script'inin gerçek testidir.
- [ ] Hub'da `.claude/` **gitignore'a eklenir.**
      Gerekçe: aynı `SKILL.md`'nin iki kopyası repoda dururken kaçınılmaz olarak ayrışır.
      Bu tür kaymayı önlemek projenin kendi amacı. Tek kaynak `skills/`; `.claude/` üretilmiş
      çıktıdır. Fresh clone sonrası ilk adım self-install olur — bunu `README.md`'ye yaz.

### Asıl doğrulama — projenin varlık sebebi

Test projesinde şunu uçtan uca çalıştır:

1. Küçük bir değişiklik yap
2. `/handoff` → `docs/handoffs/<bugün>.md` oluştu mu, `STATE.md` güncellendi mi
3. `/clear`
4. `/resume` → ajan **eski oturum geçmişi olmadan** doğru özeti ve sıradaki adımı veriyor mu

Bu test geçerse proje amacına ulaşmıştır. Geçmezse geri kalan her şey dekordur.

---

## M6 — Codex katmanı (ERTELENDİ)

**Kullanıcı kararı (2026-08-20): bu aşamaya başlanmayacak, kullanıcı açıkça "Codex'i
yapalım" demeden hiçbir Codex işi yapılmaz.** `AGENTS.md` zaten tek kaynak olduğu için
Codex bugün de temel seviyede çalışıyor — yani M6 olmadan da hub kullanılabilir durumda.
Aşağıdaki liste yalnızca referans, aktif bir görev değil:

- [ ] `.codex/config.toml`
- [ ] Skill'lerin `.agents/skills`'e köprülenmesi
- [ ] `AGENTS.md`'nin Codex'in 32KB sınırının altında kaldığının `doctor`'da kontrolü

---

## Sık yapılan hatalar

- **Şablonu canlı dosya olarak kullanmak.** `templates/` içinde gerçek veri olmaz.
- **Frontmatter'sız SKILL.md.** Skill sanırsın, aslında sadece markdown dosyasıdır.
- **`AGENTS.md`'yi şişirmek.** Her satır her oturumda token ve dikkat maliyeti. Kodda görünen
  hiçbir şey (klasör yapısı, dosya adları, bağımlılık listesi) oraya yazılmaz.
- **Aynı kuralı üç dosyaya kopyalamak.** Tek kaynak + referans. (Şu an "context bloat yapma"
  kuralı `architecture.md`, `templates/AGENTS.md` ve `skills/handoff/SKILL.md`'de var.)
- **`/init` çalıştırmak.** Ölçülmüş şekilde zararlı; hub'ın varlık sebebi bunu yapmamak.
- **`PLANS.md`'de yapılmamış işi `[x]` işaretlemek.** Sistemin güvenilirliği buna bağlı.

---

## İlerleme

- [x] M0 — Hub'ın kendi temeli
- [x] M1 — Skills
- [x] M2 — Hooks
- [x] M3 — install script
- [x] M4 — doctor
- [x] M5 — Dogfooding + uçtan uca test (2026-08-20'de geçti)
- [ ] M6 — Codex katmanı — **ertelendi**, kullanıcı isteyene kadar başlanmayacak

Son güncelleme: 2026-08-20
