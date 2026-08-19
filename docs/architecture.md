# AI Coding Workspace — Mimari

## 1. Amaç

AI Coding Workspace, yapay zeka destekli yazılım geliştirme ajanlarının uzun süreli ve çok oturumlu projelerde daha düzenli, sürdürülebilir ve kontrol edilebilir şekilde çalışmasını sağlamak amacıyla geliştirilen genel amaçlı bir altyapıdır.

Sistem belirli bir programlama dili, yapay zeka modeli, IDE veya proje türüne bağımlı değildir.

Temel amaçlar:

- Yapay zeka ajanlarının proje bağlamını verimli yönetmesini sağlamak
- Oturumlar arasında proje durumunun kaybolmasını önlemek
- Gereksiz bağlam ve token kullanımını azaltmak
- Tekrarlanan geliştirme süreçlerini standartlaştırmak
- Ajan davranışlarını otomatik kurallar ve kancalar ile kontrol etmek
- Farklı yapay zeka kodlama araçları arasında taşınabilir bir çalışma ortamı oluşturmak
- Sistemin farklı projelere kolayca uygulanabilmesini sağlamak
- İnsan geliştiricinin sistem üzerindeki kontrolünü korumak

Bu proje tek bir yazılım uygulaması geliştirmek için değil, farklı yazılım projelerinde kullanılabilecek yeniden kullanılabilir bir AI geliştirme altyapısı oluşturmak için tasarlanmıştır.

---

## 2. Kapsam

Sistem aşağıdaki problemleri çözmeye odaklanır:

- Bağlam şişmesi
- Uzun oturumların yönetimi
- Oturumlar arası süreklilik
- Proje kurallarının standartlaştırılması
- Tekrarlanan iş akışlarının otomatikleştirilmesi
- Ajan çıktılarının doğrulanması
- Proje bilgilerinin ihtiyaç halinde bağlama alınması
- Ajanların güvenli ve kontrollü çalışması

Sistem aşağıdaki konuları doğrudan çözmeyi amaçlamaz:

- Belirli bir yapay zeka modelinin eğitilmesi
- Genel amaçlı bir LLM oluşturulması
- Tamamen otonom bir yazılım şirketi veya ajan topluluğu oluşturulması
- Gereksiz şekilde karmaşık çoklu ajan sistemleri kurulması
- Projenin tüm kod tabanının yapay zeka belleğine kopyalanması

---

# 3. Temel Mimari Prensipler

## 3.1 Basitlik

Sistem mümkün olduğunca az bileşenle mümkün olduğunca fazla iş yapmalıdır.

Yeni bir bileşen yalnızca gerçek bir problemi çözüyor ve mevcut sistemden daha iyi bir çözüm sağlıyorsa eklenmelidir.

---

## 3.2 Ajan Bağımsızlığı

Altyapı tek bir yapay zeka sağlayıcısına bağımlı olmamalıdır.

Mümkün olduğunca ortak dosya formatları ve basit arayüzler kullanılmalıdır.

Örneğin:

- AGENTS.md
- Markdown belgeleri
- Git
- Shell/Python scriptleri
- Standart dosya yapıları

sistemin temel taşlarıdır.

---

## 3.3 Bağlamı Gerektiği Kadar Kullanma

Ajanın ihtiyaç duymadığı bilgiler sürekli olarak bağlam penceresinde tutulmamalıdır.

Bilgi üç seviyede ele alınır:

1. Her zaman gerekli bilgiler
2. Belirli görevlerde gerekli bilgiler
3. Geçmişte alınmış ve gerektiğinde geri getirilecek bilgiler

Bu yaklaşım bağlam şişmesini azaltır.

---

## 3.4 Kodun Bellek Olarak Kullanılması

Ajanın koddan veya Git geçmişinden kolayca çıkarabileceği bilgiler ayrıca belleğe kaydedilmemelidir.

Örneğin:

- Dosya isimleri
- Klasör yapısı
- Fonksiyon isimleri
- Sınıf isimleri
- Açıkça görülebilen bağımlılıklar

ayrıca belleğe yazılmamalıdır.

Bellekte öncelikle koddan doğrudan anlaşılamayan bilgiler tutulmalıdır.

Örneğin:

- Mimari kararların nedenleri
- Geçici teknik problemler
- Dış sistemlerle ilgili önemli bilgiler
- Daha önce denenmiş ve başarısız olmuş yaklaşımlar
- Kullanıcı tarafından belirlenmiş kalıcı tercihler

---

## 3.5 Düz Metin Önceliği

Sistemin mümkün olan en büyük bölümü insan tarafından okunabilir ve düzenlenebilir dosyalardan oluşmalıdır.

Tercih edilen formatlar:

- Markdown
- JSON
- YAML
- Python
- Shell

Kritik bilgilerin kapalı ve insan tarafından doğrudan incelenemeyen bir veritabanında tutulmasından kaçınılmalıdır.

---

## 3.6 İnsan Kontrolü

Ajan sistemin merkezinde yer alsa da son kontrol geliştiricide kalmalıdır.

Ajan:

- Kod yazabilir
- Dosya değiştirebilir
- Test çalıştırabilir
- Araştırma yapabilir
- Plan oluşturabilir

Ancak kritik veya geri döndürülmesi zor işlemler açık kurallar ve güvenlik mekanizmalarıyla sınırlandırılmalıdır.

---

# 4. Sistem Mimarisi

Sistem aşağıdaki temel bileşenlerden oluşur:

```text
                    AI Coding Workspace
                           │
                           ▼
                      AGENTS.md
                    Ana kurallar
                           │
          ┌────────────────┼────────────────┐
          │                │                │
          ▼                ▼                ▼
       Skills           Hooks            Docs
     İş akışları       Otomasyon       Referans
          │                │
          ▼                ▼
       Scripts          Validation
          │
          └───────────────┬───────────────┘
                          ▼
                       Project
                          │
              ┌───────────┴───────────┐
              ▼                       ▼
          Handoff                    Plans
       Oturum devri             Uzun görevler