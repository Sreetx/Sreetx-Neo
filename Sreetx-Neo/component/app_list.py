# component/app_parser.py

# ** The Prototype **
# ** Status: Passive **

import os, json

dirs = ["/usr/share/applications", os.path.expanduser("~/.local/share/applications")]
apps = []
seen = set()

# Mesin pencetak NerdFont biar UI lu tetep konsisten aesthetic!
def get_nerdfont(name, cat):
    n = name.lower()
    if any(x in n for x in ["term", "konsole", "alacritty", "foot"]): return "󰞷"
    if any(x in n for x in ["browser", "firefox", "chrome", "zen"]): return "󰈹"
    if any(x in n for x in ["file", "thunar", "nautilus", "dolphin"]): return "󰉋"
    if any(x in n for x in ["code", "vim", "text", "obsidian"]): return "󰨞"
    if "discord" in n: return "󰙯"
    if any(x in n for x in ["steam", "game", "heroic"]): return "󰓓"
    if any(x in n for x in ["spotify", "music"]): return "󰓇"
    if any(x in n for x in ["vlc", "video", "mpv"]): return "󰕼"
    if any(x in n for x in ["gimp", "inkscape", "krita"]): return "󰽉"
    
    # Kategori Fallback
    if cat == "Internet": return "󰖟"
    if cat == "Development": return "󰲋"
    if cat == "Graphics": return "󰽉"
    if cat == "Multimedia": return "󰝚"
    if cat == "Games": return "󰊗"
    
    # Default Icon kalo ga nemu (Logo Arch Linux mamen!)
    return "󰣆" 

for d in dirs:
    if not os.path.exists(d): continue
    for f in os.listdir(d):
        if f.endswith(".desktop"):
            try:
                name = exec_cmd = cat = ""
                with open(os.path.join(d, f), 'r', encoding='utf-8', errors='ignore') as file:
                    in_entry = False
                    for line in file:
                        line = line.strip()
                        if line == "[Desktop Entry]": in_entry = True
                        elif line.startswith("[") and in_entry: in_entry = False
                        
                        if in_entry:
                            if line.startswith("Name=") and not name: name = line[5:]
                            elif line.startswith("Exec=") and not exec_cmd: exec_cmd = line[5:]
                            elif line.startswith("Categories=") and not cat: cat = line[11:]
                            
                if name and exec_cmd and name not in seen:
                    # Bersihin %U, %F dari command exec bawaan linux
                    exec_cmd = exec_cmd.split('%')[0].strip() 
                    
                    main_cat = "System"
                    if any(x in cat for x in ["Network", "Web"]): main_cat = "Internet"
                    elif "Development" in cat: main_cat = "Development"
                    elif "Graphics" in cat: main_cat = "Graphics"
                    elif any(x in cat for x in ["Audio", "Video", "Multimedia"]): main_cat = "Multimedia"
                    elif "Game" in cat: main_cat = "Games"
                    
                    icon = get_nerdfont(name, main_cat)
                    apps.append({"name": name, "icon": icon, "exec": exec_cmd, "cat": main_cat})
                    seen.add(name)
            except Exception:
                pass

# Output murni JSON biar di-parsing QML
print(json.dumps(apps))