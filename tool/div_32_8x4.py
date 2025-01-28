def convert_txt(input_file, output_file):
    with open(input_file, 'r') as f_in, open(output_file, 'w') as f_out:
        for line in f_in:
            # 將每一行分割成8個字元的子字串
            chunks = [line[i:i+8] for i in range(0, len(line), 8)]
            # 將每個子字串寫入輸出檔案，並在每筆資料之間留一個空行
            for chunk in chunks:
                f_out.write(chunk.strip() + '\n')
            # f_out.write('\n')  # 空行

# 輸入檔案名稱
input_filename = 'C:/Users/user/side project/RISV-V CPU/tool/instruction/MD_type.txt'
output_filename = 'C:/Users/user/side project/RISV-V CPU/tool/instruction/MD_type_out.txt'

# 呼叫函式進行轉換
convert_txt(input_filename, output_filename)