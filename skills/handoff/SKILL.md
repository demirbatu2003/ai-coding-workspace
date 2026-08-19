# Handoff Skill

## Amaç

Bu Skill, mevcut AI session'ın durumunu özetleyerek bir sonraki session'ın
çalışmaya kaldığı yerden devam edebilmesini sağlar.

Amaç, geçmiş session'ın tamamını yeniden context'e taşımak yerine,
gerekli bilgileri `HANDOFF.md` üzerinden aktarmaktır.

## Ne Zaman Kullanılmalı?

Bu Skill aşağıdaki durumlarda kullanılmalıdır:

- Session sona ermeden önce
- Task başka bir session'da devam edecekse
- Uzun süren bir development task'ı geçici olarak durdurulacaksa
- Önemli bir milestone tamamlandıysa
- Mevcut project state'in kaydedilmesi gerekiyorsa

Kısa ve tamamlanmış task'larda gereksiz yere kullanılmamalıdır.

## İşlem

Handoff oluşturulurken aşağıdaki bilgiler kontrol edilmelidir:

1. Mevcut Git branch'i
2. Working tree durumu
3. Son commit'ler
4. Değiştirilen dosyalar
5. Tamamlanan işler
6. Devam eden işler
7. Açık problemler
8. Alınan önemli kararlar
9. Sonraki adımlar

## HANDOFF.md Güncelleme Kuralları

`HANDOFF.md` aşağıdaki bölümleri içermelidir:

- Goal
- Current State
- Completed
- In Progress
- Next Steps
- Key Decisions
- Open Problems
- Important Context
- Files Changed
- Last Updated

Bilgiler mümkün olduğunca kısa ve actionable olmalıdır.

Gereksiz implementation detayları,
uzun terminal output'ları veya code block'ları eklenmemelidir.

## Current State

Current State bölümünde mümkün olduğunda aşağıdaki bilgiler
yer almalıdır:

- Git branch
- Working tree status
- Build status
- Test status

Bilinmeyen bilgiler tahmin edilmemelidir.

## Next Steps

Next Steps bölümü yalnızca gerçekten yapılması gereken işleri içermelidir.

Her step:

- Açık
- Spesifik
- Actionable

olmalıdır.

Örneğin:

Yanlış:

> Projeyi geliştirmeye devam et.

Doğru:

> `src/context/retriever.py` içerisindeki retrieval logic'ini implement et
> ve ilgili testleri çalıştır.

## Key Decisions

Yalnızca sonraki session için önemli olan architectural veya technical
decision'lar eklenmelidir.

Bir decision'ın neden alındığı mümkün olduğunca belirtilmelidir.

## Open Problems

Çözülmemiş problemler açık şekilde belirtilmelidir.

Bir problem henüz araştırılmadıysa çözülmüş gibi gösterilmemelidir.

## Validation

Handoff oluşturulmadan önce mümkün olduğunda:

- Git status kontrol edilmeli
- Test durumu kontrol edilmeli
- Build durumu kontrol edilmeli
- Mevcut değişiklikler incelenmelidir

Handoff, project'in gerçek durumunu yansıtmalıdır.

## Sonuç

Handoff tamamlandığında yeni bir AI session'ın yalnızca:

1. `AGENTS.md`
2. `HANDOFF.md`

dosyalarını okuyarak mevcut project state'i anlayabilmesi hedeflenir.

Detaylı bilgi gerektiğinde ilgili `docs/`, `PLANS.md` veya source file'lara
bakılmalıdır.