with open("macos.ACT", 'rb') as act_file:
    for color in range(256):
        rgb_str = ''
        for rgb in range(3):
            value = act_file.read(1)
            hex_str = hex(value[0])[2:]
            if len(hex_str) == 1:
                rgb_str += '0' + hex_str
            else:
                rgb_str += hex_str
            
        print(str(color) + ': color_24_bit = 24\'h' + rgb_str + ';')
        rgb_str = ''