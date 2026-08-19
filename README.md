# ai-coding-workspace

Claude Code ve OpenAI Codex ile uzun süreli, çok oturumlu yazılım projeleri yürütmek için
yeniden kullanılabilir bir altyapı hub'ı.

## Problem

Yeni bir AI oturumu açıldığında ajan projenin nerede kaldığını bilmez. Bu hub, eski oturumu
binlerce token'lık geçmişiyle geri yüklemek yerine, diskte duran kısa durum dosyalarını
okuyarak sıfır bağlamla devam etmeyi sağlar.

## Nasıl çalışır

Bir hedef projeye kurulduğunda şunları bırakır:

- `AGENTS.md` — tek kaynak talimat dosyası (Claude Code, Codex ve diğer araçlar okur)
- `docs/STATE.md`, `docs/DECISIONS.md`, `docs/handoffs/` — oturumlar arası süreklilik
- `.claude/skills/` — resume, handoff, plan, review komutları
- `.claude/hooks/` — oturum başında durumu otomatik bağlama enjekte eden kancalar

Detaylı mimari için [docs/architecture.md](docs/architecture.md).

## Kurulum

```powershell
.\install.ps1 -Target ..\benim-projem
