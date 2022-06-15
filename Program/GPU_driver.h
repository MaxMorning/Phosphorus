#define GPU_BASE                0x40000000
#define GPU_OUTPUT_REG          0x00000000
#define GPU_RENDER_REG          0x00000004
#define GPU_MODE_REG            0x00000008
#define GPU_SPIRIT_CNT_REG      0x0000000c

#define GPU_SPIRIT_POS_ARRAY    0x00000100
#define GPU_TILE_MAP_ARRAY      0x00001000
#define GPU_TEXTURE_MEM         0x00002000

#define GPU_TEXTURE_SIZE        0x8000
#define GPU_TILE_MAP_SIZE       1200

#define GPU_RENDER_WIDTH        640
#define GPU_RENDER_HEIGHT       480

#ifndef REG8

#define REG8(add) *((volatile INT8U *)(add))
#define REG16(add) *((volatile INT16U *)(add))
#define REG32(add) *((volatile INT32U *)(add))

#endif

struct SpiritStruct {
    INT16U position_x;
    INT16U position_y;
    INT8U texture_idx;
    INT8U position_z;

    INT16U placeholder;
} __attribute__((packed));

void gpu_start_render(void);

void gpu_stop_render(void);

void gpu_copy_to_vram(unsigned int dst_base_offset, INT32U* src_mem_ptr, unsigned int mem_size);