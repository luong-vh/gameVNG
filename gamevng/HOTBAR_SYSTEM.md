# Hotbar System Documentation

## Overview
Hotbar system cho phép player nhặt và sử dụng items trong game. System bao gồm:

- **Hotbar UI**: 5 slots hiển thị ở dưới màn hình
- **Inventory System**: Quản lý items trong hotbar
- **Item Manager**: Xử lý logic khi sử dụng items

## Controls
- **Phím 1-5**: Chọn và SỬ DỤNG item ngay lập tức
- **Mouse wheel**: Scroll qua các slots (chỉ để xem)
- **Selected slot**: Slot được chọn có viền vàng

## Item Usage
**Health Potion**: 
- Restores 1 HP to player
- Cannot use when health is full
- Makes coin sound effect when used
- Shows debug messages in console

**How to use items:**
1. Pick up item (automatically goes to hotbar)
2. Press number key (1-5) to USE item immediately
3. Item effect applies if successful
4. Item removed from hotbar after use

**Debug Controls:**
- **H**: Add test item to hotbar
- **J**: Damage player -1 HP (để test healing)

## Components

### 1. Hotbar.gd (Scene: hotbar.tscn)
- UI component hiển thị 5 slots
- Handle input (keyboard + mouse)
- Visual feedback (selection, hover)

### 2. InventorySystem.gd (Autoload qua GameManager)
- Quản lý items trong hotbar (max 5 slots)
- Support item stacking
- Save/load system integration

### 3. ItemManager.gd (Autoload qua GameManager)  
- Define item effects (health_potion, etc.)
- Execute item usage logic

## Creating New Items

### Step 1: Create Collectible Scene
```gdscript
# Example: health_potion.gd
extends BaseCollectible

func _on_collect():
    super._on_collect()
    var texture = preload("res://path/to/icon.png")
    GUIManager.add_item_to_hotbar("health_potion", texture, 1)
```

### Step 2: Add Item Effect
```gdscript
# In ItemManager.gd, add to use_item() function:
"new_item_name":
    return use_new_item()

func use_new_item() -> bool:
    # Your item logic here
    return true
```

## Integration với hệ thống hiện tại
- **GUIManager**: Tích hợp hotbar UI
- **Save/Load**: Items được lưu trong checkpoint system
- **BaseCollectible**: Dùng để tạo items nhặt được

## Features hiện tại:
✅ Visual hotbar với 5 slots  
✅ Keyboard/mouse controls  
✅ Item stacking  
✅ Save/load integration  
✅ Health potion example  
✅ Sound effects  

## TODO (có thể mở rộng):
- Drag & drop items giữa slots
- Right-click để drop items  
- Item tooltips/descriptions
- Different item types (weapons, tools, etc.)
- Hotkey customization