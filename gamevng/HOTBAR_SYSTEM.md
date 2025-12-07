# Hotbar System Documentation

## Overview
Hotbar system cho phép player nhặt và sử dụng items trong game. System bao gồm:

- **Hotbar UI**: 5 slots hiển thị ở dưới màn hình
- **Inventory System**: Quản lý items trong hotbar
- **Item Manager**: Xử lý logic khi sử dụng items

## Controls
- **Phím 1-5**: Sử dụng item ngay lập tức
- **Mouse wheel**: Scroll qua các slots (để xem)
- **Individual slots**: Mỗi ô có border riêng biệt

## Visual Design
**Improved Hotbar UI:**
- ✅ Individual slot borders (3D effect)
- ✅ Darker background with better contrast
- ✅ Proper slot separation (4px spacing)
- ✅ Removed selection border (không cần nữa)
- ✅ Better hover effects
- ✅ Clean professional look

## Item Usage
**Health Potion**: 
- Restores 1 HP to player
- Cannot use when health is full
- Makes coin sound effect when used

**Speed Boost**:
- Increases player movement speed temporarily
- Uses existing powerup system
- Duration and multiplier từ powerup database
- Makes coin sound effect when used

**Damage Boost**:
- Increases player attack damage (visual effect for now)
- Red flashing effect khi dùng
- Makes coin sound effect when used
- TODO: Actual damage boost when attack system available

**How to use items:**
1. Pick up item (automatically goes to hotbar)
2. Press number key (1-5) to USE item immediately
3. Item effect applies if successful
4. Item removed from hotbar after use

**Debug Controls:**
- **R**: Clear ALL save data (để test item respawn)

**Item Collection:**
- Items spawn naturally trong level
- Pick up để add vào hotbar
- Pure gameplay experience!

**Testing Workflow:**
1. **Pick up items** → họ sẽ disappear và được save
2. **Press R** → clear save data  
3. **Restart level** → items respawn
4. **Level 3 auto-clears** save data mỗi lần load!

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