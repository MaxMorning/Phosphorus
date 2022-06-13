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
PositionX(Column index) [15:0] 16bit  
PositionY(Row index) [31:16] 16bit  
TextureIdx [39:32] 8bit  
PositionZ(depth) [47:40] 8bit (该值较大的spirit会覆盖较小的spirit，0表示spirit无效)

再填充16bit以保证32bit对齐
### VRAM分配
下列Address是基于Wishbone总线的BaseAddress的偏移量  
| address | content | Valid Size | 
| -- | -- | -- |
| 0x0 ~ 0xff | 控制寄存器CR | NA
| 0x100 ~ 0x0fff | Spirit Tile Position 数组 | 32 Spirit (32 * 8 = 256 Byte) |
| 0x1000 ~ 0x1fff | Tile Map | 1200 Byte
| 0x2000 ~  0x9fff| Texture Memory | 128 Tile (128 * 256 = 32768 Byte)

### 控制寄存器CR
| address | content | Valid Size | Description | 
| -- | -- | -- | -- |
| 0x0 | Output Enable | 32bit | 输出到屏幕的使能寄存器，最低位1表示有效，仅最低位可写
| 0x4 | Render Enable | 32bit | 渲染使能寄存器，最低位1表示有效，仅最低位可写
| 0x8 | Mode Select | 32bit | 模式选择寄存器，最低位1表示图像模式，0表示文本模式，仅最低位可写。目前只有图像模式
| 0xc | Spirit Tile Count | 32bit | Spirit tile数量，不超过32

## 渲染过程
```cpp
    // 使用32个流处理器计算帧数据
    // 如果传入 postitionZ 小于自身深度寄存器的值，不处理
    // 否则，如果自身myPosX < startX，不处理
    // 否则，取得自己需要处理的像素 = textureData[myPosY * 16 + myPosX - startX]；
    // 如果该像素值为0且postitionZ不为0，不处理；反之，将该值存下来，同时更新新的深度值
    void ProcessDataBy32Core(
        Data[256] textureData, // 纹理数据
        int[4] startX, // 传入纹理数据的左上像素的X坐标，处理背景时为0
        int[8] postitionZ // 深度，处理背景时为0
    );

    for (currentTileY = 0; currentTileY < (480 / 16); ++currentTileY) {
        for (currentTileX = 0; currentTileX < (640 / 16); ++currentTileX) {
            for (int[4] tileRow = 0; tileRow < 16; tileRow += 2) {
                for (int i = 0; i < SpiritTileCnt; ++i) {
                    spiritPosition = SpiritTilePosition[i];
                    if (spiritPosition.PositionZ == 0) {
                        continue;
                    }

                    if (spiritPosition.positionX > {currentTileX - 1, 4'h0} &&
                        spiritPosition.positionX < {currentTileX + 1, 4'h0} &&
                        spiritPosition.positionY > {currentTileY + 1, tileRow} &&
                        spiritPosition.positionY < {currentTileY, tileRow} + 2) {
                        // 当前spirit在待渲染的2 * 16块内

                        // 找Texture Memory取得像素值
                        // 取值时需要注意，如果只取得最后一行，返回的后16字节需要填0，否则会取到下一个tile的开头16字节。
                        askTextureTile(spiritPosition.texture_idx, ({currentTileY, tileRow} - spiritPosition.positionY));

                        Data[256] textureData = getTexture();

                        // 由32个流处理器处理
                        ProcessDataBy32Core(textureData, spiritPosition.positionX[3:0], spiritPosition.positionZ);
                    }
                }

                // 精灵图处理完，处理背景图
                askTextureTile(tileMap[currentTileY * 40 + currentTileX], tileRow);

                Data[256] textureData = getTexture();

                // 由32个流处理器处理
                ProcessDataBy32Core(textureData, 0, 0);

                // 将流处理器计算出的 32B 写入帧缓存
                WriteToFrameBuffer(currentTileX, {currentTileY, tileRow});
            }
        }
    }
    
```