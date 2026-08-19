# AGENTS.md — ai-coding-workspace

Bu repo bir **hub**: Claude Code (sonra Codex) için yeniden kullanılabilir bir çalışma
altyapısı üretir ve onu başka projelere kurar. Buradaki kurallar *bu repoyu geliştirirken*
geçerlidir, kurulan projelerde değil.

## En önemli kural: hub ≠ hedef

İki ayrı dünya var:

- **Hub** = bu repo. Kökteki `AGENTS.md`, `PLANS.md` ve `docs/` bu repoyu geliştirmek içindir.
- **Hedef** = install ile altyapının kurulduğu başka bir proje.

Hedefe giden her şey yalnızca `templates/`, `skills/`, `hooks/` altında yaşar.
Kökteki hiçbir dosya hedefe kopyalanmaz.

Yeni dosya eklerken sor: *"Bu, bu repoyu geliştirmek için mi, yoksa kurulan projeye mi
gidecek?"* Cevap ikisi birden ise iki ayrı dosyaya bölünmesi gerekiyor demektir.

## Tek kaynak kuralları

- Skill'lerin tek kaynağı `skills/`. `.claude/` self-install ile üretilen çıktıdır,
  gitignore'dadır ve elle düzenlenmez. Skill değiştirilecekse `skills/` altında değiştirilir.
- `templates/` yalnızca `.md.tmpl` uzantılı şablon içerir. İçinde bu projenin gerçek verisi
  bulunmaz — sadece `<!-- DOLDUR: ... -->` slotları ve kısa açıklamalar.
- `VERSION` sürümün tek kaynağıdır.
- Aynı kural iki dosyaya kopyalanmaz. Tek yerde tutulur, diğerinden referans verilir.

## Durum dosyaları

| Dosya | Rol | Yazım biçimi |
|---|---|---|
| `docs/STATE.md` | Şu an neredeyiz | Üzerine yazılır, hep güncel |
| `docs/handoffs/<tarih>.md` | O oturumda ne oldu, ne denendi, ne işe yaramadı | Dondurulur, düzenlenmez |
| `docs/DECISIONS.md` | Koddan anlaşılmayan neden'ler + reddedilen alternatifler | Sona eklenir |
| `PLANS.md` | Uzun görevin adımları ve ilerlemesi | Güncellenir |

`PLANS.md`'de bir maddeyi `[x]` işaretlemeden önce ilgili dosyanın diskte gerçekten var
**ve dolu** olduğu doğrulanır. Yapılmamış işi tamamlanmış göstermek bu projedeki en ciddi
hatadır — sistemin tüm güvenilirliği buna dayanır.

## Skill yazarken

- Konum: `skills/<ad>/SKILL.md`
- Geçerli YAML frontmatter zorunludur: `name` (küçük harf + tire, klasör adıyla aynı) ve
  `description`. Frontmatter'sız dosya skill değildir, sadece markdown'dır.
- `description` bir **tetikleyicidir**, dokümantasyon değil. Oturum başında yalnızca o satır
  yüklenir. Kullanıcının gerçekten yazacağı Türkçe ve İngilizce kelimeleri içermelidir.
- Gövde ~60 satırı geçmez. Daha uzun referans gerekiyorsa yanına `reference.md` konur ve
  skill oradan yönlendirir.

## Bilgi nereye ait

| Bilgi türü | Yeri |
|---|---|
| Sabit gerçek (komut, konvansiyon) | `AGENTS.md` |
| Tekrarlanan prosedür | Skill |
| Asla ihlal edilmemesi gereken kısıt | Hook |
| Gürültülü, izole yan görev | Subagent |

Kodda veya git geçmişinde görünen hiçbir şey (klasör yapısı, dosya adları, bağımlılıklar)
kalıcı talimata yazılmaz. Talimat yalnızca türetilemeyen bilgiyi taşır.

## Değişiklik yaparken

1. İlgili dosyayı oku, mevcut yapıyı anla.
2. Değişikliği küçük ve tek konuya odaklı tut.
3. Bir betik değiştirildiyse elle çalıştırılıp çıktısı görülür.
4. `docs/STATE.md` güncellenir; gerekiyorsa `PLANS.md` de.
5. Aşama başına bir commit.

Betikler platform çifti halinde yazılır: her `.ps1` için bir `.sh` eşdeğeri.
Birincil platform Windows / PowerShell.

## Doğrulama

Otomatik doğrulama henüz yok. `scripts/doctor.*` eklendiğinde bu bölüm onu çalıştırma
talimatıyla güncellenecek. O zamana kadar doğrulama elle yapılır:
betiği çalıştır, `PLANS.md` ile diski karşılaştır, `AGENTS.md` satır sayısını kontrol et.

## İnsan kontrolü

Bu repoda dosya oluşturma ve düzenlemeyi repo sahibi yapar. Ajan yönlendirir, gerekçe üretir
ve içerik önerir; **açıkça istenmedikçe dosya yazmaz.**

Silme, geri döndürülemez işlemler ve git history değiştirme açık onay gerektirir.
