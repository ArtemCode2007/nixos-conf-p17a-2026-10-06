# NixOS 26.05 + Home Manager + Hyprland — P17A update (2026-10-06)

## Что изменено

### 1. Микрофон / PipeWire
Добавлены `pavucontrol` и `qpwgraph`, Waybar -> click opens `pavucontrol`, right click opens `qpwgraph`.

Hotkeys:
- `Super + Alt + Up/Down` — microphone volume +/- 5%, maximum 200%
- `Super + Alt + M` — microphone mute
- `XF86AudioMicMute` — microphone mute

Важно: именно физический дефект "белый шум вместо голоса" нельзя безопасно исправить одной декларацией без данных с живого аудиоустройства. Конфигурация не форсирует неизвестный ALSA profile, чтобы не сломать реальный codec profile. После входа проверьте `pavucontrol` -> Input Devices и выберите физический Internal Microphone, а не Monitor of Output.

Для диагностики:
```bash
wpctl status
wpctl get-volume @DEFAULT_AUDIO_SOURCE@
```

### 2. Screenshots
`Print` теперь:
1. запускает `slurp`;
2. сохраняет PNG в `~/Pictures/Screenshots/`;
3. копирует сохраненный PNG в Wayland clipboard.

Формат имени:
`YYYY-MM-DD_HH-MM-SS.png`

### 3. llama.cpp + Open WebUI + OpenCode
- `llama.cpp` берётся из `nixpkgs-unstable` с `vulkanSupport = true` для Radeon 780M.
- `llama-server` запускается как user systemd service.
- Open WebUI запускается как NixOS service на `127.0.0.1:3000`.
- Firefox launcher добавлен в application menu.
- OpenCode получает локальный OpenAI-compatible provider `http://127.0.0.1:10000/v1`.

Open WebUI имеет native MCP support. Node.js/npm не нужны для самого MCP. Node.js нужен здесь отдельно для пользовательских Node/NPM инструментов и JavaScript-based MCP servers.

В этой конфигурации Open WebUI подключается к llama.cpp как к OpenAI-compatible API.

### 4. Локальная модель
Для OpenCode сервер настроен на:
`Qwen2.5-Coder-7B-Instruct Q4_K_M`
Первый запуск user-service `llama-server` скачивает этот GGUF из Hugging Face автоматически.

Выбран 7B-класс как более реалистичный для 16 GB RAM + Radeon 780M shared memory.

Первый старт `llama-server` может скачать GGUF через Hugging Face. После этого модель обслуживается локально.

### 5. Proton / 1920x1080
Добавлен:
```lua
xwayland = {
  force_zero_scaling = true,
}
```

и `gamescope`.

Это исправляет XWayland scaling path, но не заставляет игру уважать 1920x1080, если сама игра принудительно выбирает другое разрешение.

Для проблемных Steam-игр используйте launch option:
```text
gamescope -W 1920 -H 1080 -w 1920 -h 1080 -f -- %command%
```

### 6. 200% volume
Hotkeys now use `wpctl -l 2.0` for output and microphone.
`pavucontrol` provides per-application and per-device routing/volume control.

### 7. Новые программы
Добавлены:
- latest Node.js из `nixpkgs-unstable` (npm bundled)
- OpenCode
- Fish
- fastfetch + neofetch
- eza
- btop
- hwinfo
- lshw
- lm_sensors
- smartmontools
- mission-center
- pavucontrol
- qpwgraph
- Python 3.14 + pip + virtualenv

Старый AIMP-подобный сценарий покрывает `audacious`.

## Flake architecture

```text
flake.nix
 ├── configuration.nix
 │    └── hardware-configuration.nix
 │
 └── Home Manager
      └── home.nix
           ├── packages.nix
           └── hypr/
                ├── hyprland.lua
                ├── monitor.lua
                ├── input.lua
                ├── window.lua
                ├── windowrule.lua
                ├── bind.lua
                ├── exec.lua
                └── hyprpaper.lua
```

## Проверка

```bash
cd ~/nixos-conf
nix flake check --show-trace
sudo nixos-rebuild test --flake .#p17a --show-trace
```

После успешного test:

```bash
sudo nixos-rebuild switch --flake .#p17a --show-trace
reboot
```

После входа:

```bash
hyprctl configerrors
hyprctl monitors
wpctl status
curl http://127.0.0.1:10000/v1/models
curl http://127.0.0.1:3000
```

Open WebUI:
`http://127.0.0.1:3000`

llama.cpp API:
`http://127.0.0.1:10000/v1`

## Ограничение по MCP OAuth

Native MCP есть в Open WebUI. Для OAuth-backed MCP integrations документация Open WebUI требует `WEBUI_SECRET_KEY`. Для обычных локальных MCP integrations Node.js/npm не являются обязательными.

Для production-like OAuth setup secret следует вынести в secret manager / environmentFile, а не хранить в Git.


## Управление llama-server

```bash
systemctl --user status llama-server
journalctl --user -u llama-server -e
```

Проверка API:

```bash
curl http://127.0.0.1:10000/v1/models
```
