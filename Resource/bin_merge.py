import struct

merge_info = {
    'BootLoader.bin': 0x000,
    'ucosii.bin': 0x300,
    'texture.data': 0x10000,
    'Map.data': 0x18000
}

with open('OS.bin', 'wb') as os_file:
    current_size = 0
    for file_name, offset in merge_info:
        for i in range(offset - current_size):
            os_file.write(struct.pack('b', 255))

        with open(file_name, 'rb') as bin_file:
            bin_content = bin_file.read()
            os_file.write(bin_content)
            current_size += len(bin_content)

        print(file_name + ' Done.')

            