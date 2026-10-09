{ config, pkgs, inputs, system, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };

  llamaCpp = unstable.llama-cpp.override {
    vulkanSupport = true;
  };

  llamaServerStart = pkgs.writeShellApplication {
    name = "llama-server-start";
    runtimeInputs = [ llamaCpp ];

    text = ''
      exec llama-server \
        -hf Qwen/Qwen2.5-Coder-7B-Instruct-GGUF:Q4_K_M \
        --host 127.0.0.1 \
        --port 10000 \
        --ctx-size 8192 \
        --n-gpu-layers 99 \
        --ui-mcp-proxy
    '';
  };

  mcpProxyStart = pkgs.writeShellApplication {
    name = "mcp-proxy-start";
    runtimeInputs = [ pkgs.uv ];

    text = ''
      exec uvx --with 'mcp>=1.17,<2.0.0' mcp-proxy==0.12.0 \
        --host 127.0.0.1 \
        --port 8001 \
        --stateless \
        --named-server-config "$HOME/.config/mcp/mcp-servers.json"
    '';
  };

  blenderMcpInstallAddon = pkgs.writeShellApplication {
    name = "blender-mcp-install-addon";
    runtimeInputs = [ pkgs.uv ];

    text = ''
      exec uvx mcp-for-blender==2.1.1 install-addon
    '';
  };

  llamaUi = pkgs.writeShellApplication {
    name = "llama-ui";
    runtimeInputs = [ pkgs.firefox ];

    text = ''
      exec firefox --new-window http://127.0.0.1:10000
    '';
  };
in
{
  # MCP definitions are kept in a plain JSON file so a beginner can edit them.
  # The same file is compatible with llama-server's --mcp-servers-config option.
  xdg.configFile."mcp/mcp-servers.json" = {
    source = ./mcp/mcp-servers.json;
    force = true;
  };

  # Manual launchers. They are regular user commands and do not start on login.
  home.packages = [
    llamaServerStart
    mcpProxyStart
    blenderMcpInstallAddon
    llamaUi
  ];
}
