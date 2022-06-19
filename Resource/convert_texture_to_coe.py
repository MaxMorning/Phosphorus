import sys

def convert_hex(byte):
    hex_str = hex(byte)[2:]
    if len(hex_str) == 1:
        hex_str = '0' + hex_str
    
    return hex_str


if __name__ == "__main__":
    with open(sys.argv[1], 'rb') as bin_file:
        with open('texture0.coe', 'w') as coe_0_file:
            with open('texture1.coe', 'w') as coe_1_file:
                bin_content = bin_file.read()

                coe_0_file.write('memory_initialization_radix = 16;\nmemory_initialization_vector =\n')
                coe_1_file.write('memory_initialization_radix = 16;\nmemory_initialization_vector =\n')

                # cnt = 0

                for idx in range(0, len(bin_content), 4):
                    word = bin_content[idx:idx + 4]
                    
                    if idx % 256 < 128:
                        for i in range(3, -1, -1):
                            coe_0_file.write(convert_hex(word[i]))
                        
                        coe_0_file.write('\n')
                    else:
                        for i in range(3, -1, -1):
                            coe_1_file.write(convert_hex(word[i]))
                        coe_1_file.write('\n')

                
                # for byte in bin_content:
                #     if cnt % 256 < 128:
                #         if cnt % 4 == 0:
                #             coe_0_file.write('\n')

                #     else:
                #         if cnt % 4 == 0:
                #             coe_1_file.write('\n')

                #     hex_str = hex(byte)[2:]
                #     if len(hex_str) == 1:
                #         hex_str = '0' + hex_str

                #     if cnt % 256 < 128:
                #         coe_0_file.write(hex_str)

                #     else:
                #         coe_1_file.write(hex_str)

                #     cnt += 1