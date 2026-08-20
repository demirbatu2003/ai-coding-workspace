# Kullanım Rehberi — bu projeye kurulan AI hub'ı nasıl çalışır

Bu dosya, `ai-coding-workspace` hub'ının bu projeye kurduğu sistemin **kullanıcı
kılavuzudur**. Kod içermez, sadece nasıl çalıştığını ve ne yapman gerektiğini anlatır.

---

## 1. Zihinsel model — iki dünya

```
ai-coding-workspace (HUB)              bu proje (HEDEF)
hub'ı geliştiren ayrı repo      →      install ile üretilen sonuç
```

Hub, bu projeye bir kez "kuruldu". Hub'ın kendisini bir daha bu projede açmana gerek
yok — burada sadece kurduğu dosyaları kullanıyorsun.

## 2. Kurulumun bıraktığı dosyalar

```
AGENTS.md               ← proje kuralları (doldurulmuş olmalı)
CLAUDE.md                ← @AGENTS.md import, dokunma
PLANS.md                 ← uzun görev takibi
docs/STATE.md             ← şu an neredeyiz (canlı, üzerine yazılır)
docs/DECISIONS.md          ← koddan anlaşılmayan kararlar (kalıcı, sona eklenir)
docs/handoffs/              ← oturum devir kayıtları (dondurulmuş, silinmez)
docs/USAGE.md               ← bu dosya
.claude/skills/               ← handoff, resume, plan, review
.claude/hooks/                 ← SessionStart, PreCompact
.claude/settings.json           ← hook kayıtları
.ai-workspace/version.json       ← kurulum makbuzu
```

**Kurulumdan sonra elle yapılması gereken tek şey:** `AGENTS.md`, `PLANS.md`,
`docs/STATE.md`, `docs/DECISIONS.md` içindeki `<!-- DOLDUR: -->` alanlarını doldurmak —
bu projenin gerçek build/test komutları, konvansiyonları, hedefi. Bunu AI'a yaptırma
(`/init` gibi); ölçülmüş şekilde zararlı olduğu gösterilmiş bir yaklaşım. Elle, kısa
tutarak (≤200 satır) doldur.

## 3. Günlük kullanım — hangi komut ne zaman

| Ne zaman | Ne yaz | Ne olur |
|---|---|---|
| Oturuma başlarken | (otomatik) | `SessionStart` hook'u `STATE.md` + en yeni handoff + git durumunu kendiliğinden bağlama koyar |
| Hook çalışmadıysa / emin olmak istersen | `/resume` veya "nerede kalmıştık" | Aynı bilgiyi okuyup kısa özet + sıradaki adım verir |
| Çok adımlı bir görev başlarken | `/plan` veya "planla" | Kod yazmadan `PLANS.md`'ye adım listesi çıkarır |
| Bir değişikliği incelettirmek istersen | `/review` veya "incele" | Diff'i düzeltmeden inceler, bulgu raporlar |
| Oturumu kapatırken | `/handoff` veya "oturumu kapat" | `STATE.md`'yi günceller + `docs/handoffs/<tarih>.md` yazar |

**Altın kural:** her oturumu `/handoff` ile kapat, her yeni oturumda (otomatik ya da
`/resume` ile) devam et. Sistemin bütün değeri bu ikisinin etrafında dönüyor.

## 4. Tipik bir gün

```
1. Projeyi aç → Claude Code otomatik STATE.md + son handoff'u okur
2. İstersen /resume ile teyit et
3. Çalış — normal iş
4. Bitirmeden/ara verirken → /handoff
5. Yarın → 1'e dön
```

Aradan geçen süre, açtığın diğer proje, hiçbir şey fark etmez — durum diskte, git'te,
kalıcı.

## 5. Aynı gün birden fazla `/handoff`

Sorun değil. Her çağrı yeni bir dosya üretir: `docs/handoffs/<tarih>.md`,
`<tarih>-2.md`, `<tarih>-3.md`, ... Üzerine yazma yok. `/resume` her zaman **en son
değiştirilen** dosyayı bulur (dosya adının alfabetik sırasına değil, gerçek
değiştirilme zamanına bakar).

## 6. Bakım — `doctor`

`scripts/doctor.ps1`/`.sh`, projenin durumunu kontrol eder: `AGENTS.md` boyutu,
`STATE.md` tazeliği, `PLANS.md`'deki `[x]` işaretlerinin gerçekliği, skill
frontmatter'ları, doldurulmamış `<!-- DOLDUR: -->` kalıntıları, kurulu sürüm/hub sürüm
farkı.

**Önemli sınır:** `doctor` ve `.githooks/pre-commit` şu an install ile bu projeye
otomatik kopyalanmıyor — yalnızca hub'ın kendi reposunda çalışır. Bu projede sağlık
kontrolü yapmak istersen, hub'ı bulunduğu yerden şöyle çalıştır:

```powershell
<hub-yolu>\scripts\doctor.ps1 -Target <bu-projenin-yolu>
```

## 7. Kısacası, senin yapman gerekenler

1. `<!-- DOLDUR: -->` alanlarını elle doldur (bir kere, kurulumdan sonra).
2. Çalışırken hiçbir şey yapmana gerek yok — hook otomatik.
3. Oturumu kapatırken `/handoff` de.
4. Ara sıra hub'ı elle çalıştırarak `doctor` ile sağlık kontrolü yap.
