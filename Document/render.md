# Phosphorus如何渲染？
Phosphorus渲染分辨率初步定为640 * 480;  
Phosphorus用于渲染的数据来自纹理内存TextureMemory。  

## 数据结构
### Texture
__index__  
8bit unsigned integer

__content__  
16Row * 16Col * 8bit = 2048bit = 256 Byte of VGA 256 color  
1 byte / pixel

### Spirit Tile Position
PositionX(Column index) 16bit  
PositionY(Row index) 16bit  
TextureIdx 8bit  
PositionZ(depth) 8bit (该值较大的spirit会覆盖较小的spirit，0表示spirit无效)
### VRAM分配
下列Address是基于Wishbone总线的BaseAddress的偏移量  
| address | content | Valid Size | 
| -- | -- | -- |
| 0x0 ~ 0xff | 控制寄存器CR | NA
| 0x100 ~ 0x0fff | Spirit Tile Position 数组 | 32 Spirit (32 * 6 = 192 Byte) |
| 0x1000 ~ 0x1fff | Tile Map | 1200 Byte
| 0x2000 ~  0x9fff| Texture Memory | 128 Tile (128 * 256 = 32768 Byte)

### 控制寄存器CR
| address | content | Valid Size | Description | 
| -- | -- | -- | -- |
| 0x0 | Output Enable | 32bit | 输出到屏幕的使能寄存器，最低位1表示有效，仅最低位可写
| 0x4 | Render Enable | 32bit | 渲染使能寄存器，最低位1表示有效，仅最低位可写
| 0x8 | Mode Select | 32bit | 模式选择寄存器，最低位1表示图像模式，0表示文本模式，仅最低位可写。目前只有图像模式
## 渲染过程
### 1. 读取控制寄存器，检查0x0地址的寄存器是否为1
