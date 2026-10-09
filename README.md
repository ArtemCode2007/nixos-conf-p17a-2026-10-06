# NixOS 26.05 + Home Manager + Hyprland — P17A

## Назначение

Эта конфигурация рассчитана на Maibenben Perfectum P17A-R788UM и разделяет:

- NixOS — системные компоненты;
- Home Manager — пользовательские программы и настройки;
- Hyprland — графическую сессию;
- llama.cpp и MCP — ручной запуск по требованию.

## Что изменено

### 1. Убрано из автозапуска и удалено

Open WebUI больше не устанавливается и не запускается. Удалены его NixOS service и `.desktop` launcher.

`llama-server` больше не является user systemd service: он не стартует при входе в систему.

`mcpo` полностью удалён из конфигурации. Вместо него используется `mcp-proxy`, запускаемый через `uvx` в явно закреплённой версии `0.12.0`.

### 2. AppImage

AppImage включён штатным способом NixOS:

```nix
programs.appimage = {
  enable = true;
  binfmt = true;
};
```

Теперь `.AppImage` можно запускать как обычный исполняемый файл. Отдельный AppImage в конфигурацию не добавлен, потому что в исходном списке не указано конкретное приложение.

### 3. Аналог Microsoft To Do

Добавлен `planify` как графический task manager.

### 4. Аналог 7-Zip / NanoZip

Добавлены:

- `peazip` — графический архиватор;
- `p7zip` — CLI-инструменты `7z`/`7za`/`7zr`.

### 5. Blender MCP + DuckDuckGo MCP

Конфигурация MCP находится в:

```text
~/.config/mcp/mcp-servers.json
```

Файл содержит два MCP-сервера:

```json
{
  "mcpServers": {
    "blender": {
      "command": "uvx",
      "args": [
        "mcp-for-blender==2.1.1"
      ],
      "env": {
        "BLENDER_HOST": "127.0.0.1",
        "BLENDER_PORT": "9876"
      }
    },
    "duckduckgo": {
      "command": "uvx",
      "args": [
        "--with",
        "duckduckgo-mcp-server[browser]",
        "duckduckgo-mcp-server",
        "--search-backend",
        "auto"
      ]
    }
  }
}
```

`mcp-for-blender` подключается к аддону Blender через `127.0.0.1:9876`. После установки конфигурации один раз установите аддон в Blender:

```bash
uvx mcp-for-blender install-addon
```

Затем в Blender включите `Interface: MCP for Blender` и запустите MCP Server. Для удобства конфигурация также создаёт команду:

```bash
blender-mcp-install-addon
```

Текущая документация проекта использует именно `mcp-for-blender` и рекомендует `install-addon`.

### 6. Почему здесь используется mcp-proxy, а не mcpo

`mcpo` переводит MCP в OpenAPI. Для MCP Servers в Web UI llama.cpp нужен именно MCP HTTP/SSE endpoint. `mcp-proxy` предназначен для преобразования локального stdio MCP в SSE/Streamable HTTP и умеет публиковать именованные серверы по отдельным URL.

Запуск всех MCP вручную:

```bash
mcp-proxy-start
```

Фактически команда запускает `mcp-proxy==0.12.0` через `uvx`:

```bash
uvx mcp-proxy==0.12.0 --host 127.0.0.1 --port 8001 \
  --named-server-config ~/.config/mcp/mcp-servers.json
```

Конфигурация `mcp-proxy` публикует серверы по адресам:

```text
Blender:    http://127.0.0.1:8001/servers/blender/sse
DuckDuckGo: http://127.0.0.1:8001/servers/duckduckgo/sse
```

### 7. llama.cpp

`llama.cpp` по-прежнему устанавливается с Vulkan support для Radeon 780M, но `llama-server` не запускается автоматически. Вместо systemd service добавлена обычная пользовательская команда:

```bash
llama-server-start
```

Она запускает:

```text
http://127.0.0.1:10000
```

и включает CORS proxy для MCP Web UI через:

```text
--ui-mcp-proxy
```

Это соответствует механизму `Use llama-server proxy` в окне добавления MCP-сервера.

Для открытия встроенного Web UI добавлена команда:

```bash
llama-ui
```

### 8. Подключение MCP через Web UI llama.cpp

1. В одном терминале запустите:

```bash
mcp-proxy-start
```

2. Во втором терминале запустите:

```bash
llama-server-start
```

3. Откройте Web UI:

```bash
llama-ui
```

4. В окне **MCP Servers → Add New MCP Server** используйте:

| Поле | Blender | DuckDuckGo |
|---|---|---|
| Server URL | `http://127.0.0.1:8001/servers/blender/sse` | `http://127.0.0.1:8001/servers/duckduckgo/sse` |
| Display name | `Blender MCP` | `DuckDuckGo MCP` |
| Authorization | выключено | выключено |
| Custom Headers | не требуются | не требуются |
| Use llama-server proxy | включить | включить |

URL заканчивается на `/sse`, поэтому Web UI llama.cpp распознаёт SSE transport.

## Важно про llama.cpp MCP

У `llama-server` есть два разных MCP-механизма, их не следует путать:

### Вариант A — прямой stdio MCP

llama.cpp умеет сам запускать stdio MCP через:

```bash
llama-server ... --mcp-servers-config ~/.config/mcp/mcp-servers.json
```

Это обходится без внешнего proxy.

### Вариант B — Web UI + HTTP/SSE MCP

Здесь используется именно этот вариант, потому что он соответствует вашему сценарию с окном **MCP Servers** и ссылкой для вставки. `mcp-proxy` публикует локальные stdio MCP как HTTP/SSE endpoint, а `--ui-mcp-proxy` позволяет встроенному Web UI llama.cpp обращаться к ним через server-side CORS proxy.

## Управление

### Запустить llama.cpp вручную

```bash
llama-server-start
```

Остановить — `Ctrl+C` в том же терминале.

### Запустить MCP proxy вручную

```bash
mcp-proxy-start
```

Остановить — `Ctrl+C`.

### Проверка портов

```bash
ss -ltnp | grep -E ':8001|:10000'
```

## Проверка конфигурации

```bash
nix flake check --show-trace
sudo nixos-rebuild test --flake .#p17a --show-trace
```

После успешной проверки:

```bash
sudo nixos-rebuild switch --flake .#p17a --show-trace
```

После входа в Hyprland:

```bash
hyprctl configerrors
wpctl status
```

После ручного запуска llama.cpp:

```bash
curl http://127.0.0.1:10000/v1/models
```

После ручного запуска MCP proxy:

```bash
curl http://127.0.0.1:8001/status
```

## Архитектура файлов

```text
flake.nix
 ├── configuration.nix
 │    └── hardware-configuration.nix
 │
 └── Home Manager
      └── home.nix
           ├── packages.nix
           ├── mcp.nix
           ├── mcp/
           │    └── mcp-servers.json
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

## Источники MCP

- Blender MCP: https://github.com/ahujasid/mcp-for-blender
- DuckDuckGo MCP: https://github.com/nickclyde/duckduckgo-mcp-server
- MCP proxy: https://github.com/sparfenyuk/mcp-proxy (0.12.0)
