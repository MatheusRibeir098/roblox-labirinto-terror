#!/usr/bin/env python3
"""
deploy.py — Envia scripts .lua do repositório para o Roblox via Open Cloud API
Uso: python3 deploy.py
"""

import os, json, time, requests
from pathlib import Path

# Configurações
API_KEY_FILE = os.path.expanduser("~/.roblox-api-key")
UNIVERSE_ID  = "10232472687"
PLACE_ID     = "77285087788790"
BASE_URL     = f"https://apis.roblox.com/cloud/v2/universes/{UNIVERSE_ID}/places/{PLACE_ID}/instances"

# Mapa: arquivo .lua → Instance ID no Roblox
# Para adicionar um novo script: crie o script vazio no Studio, salve,
# rode python3 deploy.py --list para ver o ID, e adicione aqui.
SCRIPTS = {
    "scripts/MonstroIA.lua":   "01f61402-1bc3-1137-0a29-324800000a82",
    "scripts/TeleScript.lua":  "65797ea6-ae74-2671-033a-5204000c66b0",
}

def get_api_key():
    with open(API_KEY_FILE) as f:
        return f.read().strip()

def wait_operation(op_path, headers):
    for _ in range(10):
        time.sleep(2)
        r = requests.get(f"https://apis.roblox.com/cloud/v2/{op_path}", headers=headers)
        d = r.json()
        if d.get("done"):
            return d
    return None

def deploy_script(lua_file, instance_id, headers):
    path = Path(lua_file)
    if not path.exists():
        print(f"  ⚠️  Arquivo não encontrado: {lua_file}")
        return False

    source = path.read_text(encoding="utf-8")
    payload = {
        "engineInstance": {
            "Id": instance_id,
            "Details": {"Script": {"Source": source}}
        }
    }

    r = requests.patch(f"{BASE_URL}/{instance_id}", headers=headers, json=payload)
    d = r.json()

    if "path" not in d:
        print(f"  ❌ Erro: {d}")
        return False

    result = wait_operation(d["path"], headers)
    if result and result.get("error"):
        print(f"  ❌ {result['error']['message']}")
        return False

    print(f"  ✅ {path.name} → enviado!")
    return True

def list_scripts(headers):
    """Lista todos os scripts do ServerScriptService com seus IDs"""
    SSS_ID = "44b188da-ce63-2b47-02e9-c68d0048309e"
    r = requests.get(f"{BASE_URL}/{SSS_ID}:listChildren", headers=headers)
    op = r.json()["path"]
    time.sleep(3)
    result = requests.get(f"https://apis.roblox.com/cloud/v2/{op}", headers=headers).json()
    print("\nScripts no ServerScriptService:")
    for inst in result.get("response", {}).get("instances", []):
        e = inst["engineInstance"]
        details = e.get("Details", {})
        if any(t in details for t in ["Script", "LocalScript", "ModuleScript"]):
            print(f"  {e['Name']} → {e['Id']}")

def pull_scripts(headers):
    """Baixa os scripts do Roblox para arquivos .lua locais"""
    SSS_ID = "44b188da-ce63-2b47-02e9-c68d0048309e"
    r = requests.get(f"{BASE_URL}/{SSS_ID}:listChildren", headers=headers)
    op = r.json()["path"]
    time.sleep(3)
    result = requests.get(f"https://apis.roblox.com/cloud/v2/{op}", headers=headers).json()

    Path("scripts").mkdir(exist_ok=True)
    for inst in result.get("response", {}).get("instances", []):
        e = inst["engineInstance"]
        details = e.get("Details", {})
        for t in ["Script", "LocalScript", "ModuleScript"]:
            if t in details:
                source = details[t].get("Source", "")
                fname = f"scripts/{e['Name']}.lua"
                Path(fname).write_text(source, encoding="utf-8")
                print(f"  ⬇️  {e['Name']} → {fname}")

if __name__ == "__main__":
    import sys
    headers = {"x-api-key": get_api_key(), "Content-Type": "application/json"}

    if "--list" in sys.argv:
        list_scripts(headers)
    elif "--pull" in sys.argv:
        print("Baixando scripts do Roblox...")
        pull_scripts(headers)
        print("Feito!")
    else:
        print("🚀 Deploy: enviando scripts para o Roblox...\n")
        ok = 0
        for lua_file, instance_id in SCRIPTS.items():
            print(f"→ {lua_file}")
            if deploy_script(lua_file, instance_id, headers):
                ok += 1
        print(f"\n✅ {ok}/{len(SCRIPTS)} scripts enviados!")
