def merge_binary_to_hex(binary_lines):
    # 將每行二進制數字串合併成一個串
    merged_binary = ''.join(binary_lines)
    # 將二進制數字串轉換為32位元的二進制數字
    binary_32bit = merged_binary.zfill(32)
    # 將32位元的二進制數字串轉換為十六進制數字
    hex_number = hex(int(binary_32bit, 2))[2:].upper()
    return binary_32bit, hex_number

if __name__ == "__main__":
    binary_lines = [
        '00000000',
        '00000000',
        '00000010',
        '00010011'
    ]
    binary_32bit, hex_number = merge_binary_to_hex(binary_lines)
    print("32位元的二進制數字:", binary_32bit)
    print("對應的十六進制數字:", hex_number)


    #00000000000000000000001000010011